#!/usr/bin/env nix develop --command fish 
# vim: ft=fish

if ! set -q $GITHUB_RUN_NUMBER
  set GITHUB_RUN_NUMBER "0"
end
if ! set -q $GITHUB_STEP_SUMMARY 
  set GITHUB_STEP_SUMMARY /dev/stdout
end

set ver "$(date +'%g.%m.')$GITHUB_RUN_NUMBER"
set charts (fd Chart.yaml -x echo \{//\})

echo generated version: $ver

for i in (fd Chart.yaml)
  yq -i -y ".version = \"$ver\"" $i
  yq -i -y ".appVersion = \"$ver\"" $i
end

set packages
for i in $charts
  set i (string replace './' '' $i)

  helm package $i
  helm publish $i-* {$REGISTRY}/{$IMAGE_NAME}

  set packages $packages $i
end

echo packages: $packages
echo summaryfile: $GITHUB_STEP_SUMMARY

echo "# Built packages
" >> $GITHUB_STEP_SUMMARY
for pack in $packages
  echo "- $pack, $(echo $pack-*)"
end >>$GITHUB_STEP_SUMMARY

echo "registry: {$REGISTRY}/{$IMAGE_NAME}"

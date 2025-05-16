#!/usr/bin/env nix develop --command fish 
# vim: ft=fish

# check hard requirements
# NOTE: `begin; [cmd...]; end` blocks evaluate commands returning the first failure or the last success
if ! begin; set -q $OCI_USERNAME; set -q $OCI_PASSWORD; set -q $REGISTRY; set -q $IMAGE_NAME; end
  echo "missing required environment variables:"
  echo "- \$OCI_USERNAME"
  echo "- \$OCI_PASSWORD"
  echo "- \$REGISTRY"
  echo "- \$IMAGE_NAME"
  exit 1
end

# fallback for required variables
if ! set -q $GITHUB_RUN_NUMBER
  echo "WARN: required variable \$GITHUB_RUN_NUMBER is not present. falling back to 0"
  set GITHUB_RUN_NUMBER "0"
end
if ! set -q $GITHUB_STEP_SUMMARY 
  echo "WARN: required variable \$GITHUB_STEP_SUMMARY is not present. falling back to '/dev/stdout'"
  set GITHUB_STEP_SUMMARY /dev/stdout
end

# generate new version id
set helmVersion "$(date +'%g.%m.')$GITHUB_RUN_NUMBER"
echo "generated version: $ver"

set charts (fd Chart.yaml -x echo \{//\})

for i in (fd Chart.yaml)
  set appVersion latest
  set repo (cat (string replace Chart.yaml .repository $i))

  set appVersion (curl -H "Authorization: Bearer $OCI_PASSWORD" \
                  -s "https://ghcr.io/v2/$repo/tags/list" \
                  | jq -r 'select(startswith("production"))|sort|reverse|.[0]'
                  )

  yq -i -y ".version = \"$helmVersion\"" $i
  yq -i -y ".appVersion = \"$appVersion\"" $i
# end

# login in the OCI repository
helm registry login \
  -u {$OCI_USERNAME} \
  -p {$OCI_PASSWORD} \
  {$REGISTRY}

set packages
for i in $charts
  helm package $i
  helm push $i-* {$REGISTRY}/{$IMAGE_NAME}

  set packages $packages $i
end

#
# Git PR
#
git config set "email" "$GITHUB_ACTOR@users.noreply.github.com"
git config set "name" "github-actions"


#
# Summary
#
begin
  echo "packages: $packages"
  echo "summaryfile: $GITHUB_STEP_SUMMARY"

  echo "# Built helm charts:"

  for pack in $packages
    echo "- $pack, **$(echo $pack-*)**"
  end

  echo "
+---------------+-----------------------+
| registry      | $REGISTRY/$IMAGE_NAME |
| chart version | $ver                  |
+---------------+-----------------------+
"
end  >> $GITHUB_STEP_SUMMARY

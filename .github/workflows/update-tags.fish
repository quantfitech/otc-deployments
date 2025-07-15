#!/usr/bin/env nix develop --command fish 

function semver_parse
    string split '.' (string replace 'v' '' $argv[1])
end

function semver_inc_patch
    set s (semver_parse $argv[1])
    set s[3] (math $s[3] + 1)
    string join '.' $s
end

function check_err
    set t (echo $argv[1] | jq 'has("errors")')
    if test $t = true
        echo ERROR: $argv[2]. $argv[1]
        return 1
    end
end

set basicauth (echo -n "$OCI_USERNAME:$OCI_PASSWORD" | base64 -w0)

for chartfile in (fd Chart.yaml)
    set appVersion latest
    set repo (string replace 'ghcr.io/' '' (yq -r '.image.repository' (string replace 'Chart.yaml' 'values.yaml' $chartfile)))

    echo "chart $chartfile using repo: $repo"

    set token (curl -H "Authorization: Basic $basicauth" -L -s \
    "https://ghcr.io/token?service=ghcr.io&scope=repository:$repo:pull")
    if check_err $token "requesting token for $repo"
        continue
    end

    set token (echo $token| jq -r '.token')

    echo "token: " $token

    set appVersion (curl -H "Authorization: Bearer $token" -s "https://ghcr.io/v2/$repo/tags/list")
    if check_err $appVersion "listing repository tags for $repo"
        continue
    end

    set out (echo -n $appVersion | jq -r '.tags|select(startswith("production"))|sort|reverse|.[0]')

    set output (curl -H "Authorization: Bearer $token" -s "https://ghcr.io/v2/$repo/tags/list")
    check_err $output "error requesting tags/list for repo $repo"

    set appVersion (echo $output | jq -r '[.[]| select(contains("production"))]|sort|reverse|first')
    echo "found latest appVersion for $chartfile: $appVersion"

    yq -i -y ".appVersion = \"$appVersion\"" $chartfile
end

# update helm chart readmes
echo "updating helm documentation"
helm-docs

#
# Git update
#
git config set "user.email" "$GITHUB_ACTOR@users.noreply.github.com"
git config set "user.name" github-actions
git add ./*/Chart.yaml
git add ./*/README.md
git commit -m 'chore: update appVersion to latest'
git push

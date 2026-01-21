#!/bin/sh

runner_status=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/orgs/$GITHUB_OBJECT/actions/runners" \
  | jq -r --arg myhost "$HOSTNAME" '.runners[] | select(.name == $myhost) | .status')

if [ -z "$runner_status" ]; then
    echo "GitHub Runner is not registered"
    exit 1
fi
echo "GitHub Runner is $runner_status"
if [ "$runner_status" = "offline" ]; then
    exit 1
fi
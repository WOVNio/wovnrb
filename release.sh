#!/bin/bash

version_file=lib/wovnrb/version.rb

if [ -z "$CIRCLECI" ]; then
  echo "This script runs only on CircleCI"
  exit
fi

changed_files=`git diff --name-only HEAD~`
is_version_file_changed=`echo $changed_files | grep $version_file`
if [ -z "$is_version_file_changed" ]; then
  echo "This commit does not change $version_file"
  exit
fi

curl -u $RUBYGEMS_USERNAME:$RUBYGEMS_PASSWORD https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials
git config user.name $GITHUB_USERNAME
git config user.email $GITHUB_EMAIL
bundle exec rake build
bundle exec rake release

#!/usr/bin/env bash
set -eux
export AWS_PROFILE="wovn-code-staging-pipeline"
export AWS_REGION="us-west-2"
export ECR_HOST="257024234524.dkr.ecr.us-west-2.amazonaws.com"
export REPO_NAME_WOVNRB="wovnrb"
export REPO_NAME_NGINX="wovnrb-nginx"
export CLUSTER_NAME="wovn-library-testing"
PROJECT_DIR=$(dirname "$0")/../../..

commit_hash=$(git rev-parse --short HEAD)
image_tag="${commit_hash}"

PROJECT_TOKEN=$1
DEFAULT_LANG=$2
SUPPORTED_LANGS=$3

sed -i "s#<PROJECT_TOKEN>#${PROJECT_TOKEN}#g" ${PROJECT_DIR}/docker/rails/TestSite/config/application.rb
sed -i "s#<DEFAULT_LANG>#${DEFAULT_LANG}#g" ${PROJECT_DIR}/docker/rails/TestSite/config/application.rb
sed -i "s#<SUPPORTED_LANGS>#${SUPPORTED_LANGS}#g" ${PROJECT_DIR}/docker/rails/TestSite/config/application.rb

cd ${PROJECT_DIR}
echo "$(PWD)"
sh build.sh "${REPO_NAME_WOVNRB}":"${image_tag}"
sh docker/nginx/build.sh "${REPO_NAME_NGINX}":"${image_tag}"

source tag_and_push_image.sh

set +x
$(aws ecr get-login --no-include-email --region "${AWS_REGION}" --profile "${AWS_PROFILE}")
set -x

tag_and_push_image "${AWS_REGION}" "${REPO_NAME_WOVNRB}" "${image_tag}" "staging"
tag_and_push_image "${AWS_REGION}" "${REPO_NAME_NGINX}" "${image_tag}" "staging"

sed -i "s#wovnrb:latest#"${REPO_NAME_WOVNRB}":"${image_tag}"#g" taskdef.json
sed -i "s#wovnrb-nginx:latest#"${REPO_NAME_NGINX}":"${image_tag}"#g" taskdef.json

TASKDEF_REVISION=$(aws ecs register-task-definition \
                         --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
                         --cli-input-json file://$(pwd)/taskdef.json \
                      | jq ."taskDefinition.revision")
echo "${TASKDEF_REVISION}"
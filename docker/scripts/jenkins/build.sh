#!/usr/bin/env bash
set -eux
export AWS_PROFILE="wovn-code-staging-pipeline"
export AWS_REGION="us-west-2"
export ECR_HOST="257024234524.dkr.ecr.us-west-2.amazonaws.com"
export REPO_NAME_WOVNRB="wovnrb"
export REPO_NAME_NGINX="wovnrb-nginx"
export CLUSTER_NAME="wovn-library-testing"
PROJECT_DIR=$(dirname "$0")/../../../

commit_hash=$(git rev-parse --short HEAD)
image_tag="${commit_hash}"

sh ${PROJECT_DIR}/docker/rails/build.sh "${REPO_NAME_WOVNRB}":"${image_tag}"
sh ${PROJECT_DIR}/docker/nginx/build.sh "${REPO_NAME_NGINX}":"${image_tag}"

source tag_and_push_image.sh

# login docker to ECR repository (DO NOT LOG COMMAND INCLUDING TOKEN)
set +x
$(aws ecr get-login --no-include-email --region "${AWS_REGION}" --profile "${AWS_PROFILE}")
set -x

tag_and_push_image "${AWS_REGION}" "${REPO_NAME_WOVNRB}" "${image_tag}" "staging"
tag_and_push_image "${AWS_REGION}" "${REPO_NAME_NGINX}" "${image_tag}" "staging"

sed -i '.bak' "s#<PLACEHOLDER_IMAGE_NAME>#"${ECR_HOST}"/"${REPO_NAME_WOVNRB}":"${image_tag}"#g" taskdef.json
sed -i '.bak' "s#wovnrb-nginx:latest#"${REPO_NAME_NGINX}":"${image_tag}"#g" taskdef.json

TASKDEF_REVISION=$(aws ecs register-task-definition \
                         --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
                         --cli-input-json file://$(pwd)/taskdef.json \
                      | jq ."taskDefinition.revision")
echo "${TASKDEF_REVISION}"
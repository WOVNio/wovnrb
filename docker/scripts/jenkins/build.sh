#!/usr/bin/env bash
set -eux
export AWS_PROFILE="wovn-code-staging-pipeline"
export AWS_REGION="us-west-2"
export ECR_HOST="257024234524.dkr.ecr.us-west-2.amazonaws.com"
REPO_NAME_WOVNRB="wovnrb"
REPO_NAME_NGINX="wovnrb-nginx"
CLUSTER_NAME="wovn-library-testing"
TASKDEF_FAMILY_NAME="wovnrb"
ECS_SERVICE_NAME="wovnrb"
PROJECT_DIR=$(dirname "$0")/../../..

commit_hash=$(git rev-parse --short HEAD)
image_tag="${commit_hash}"

sh ${PROJECT_DIR}/build.sh "${REPO_NAME_WOVNRB}":"${image_tag}"
sh ${PROJECT_DIR}/docker/nginx/build.sh "${REPO_NAME_NGINX}":"${image_tag}"

source ${PROJECT_DIR}/docker/scripts/jenkins/tag_and_push_image.sh

set +x
$(aws ecr get-login --no-include-email --region "${AWS_REGION}" --profile "${AWS_PROFILE}")
set -x

tag_and_push_image "${AWS_REGION}" "${REPO_NAME_WOVNRB}" "${image_tag}" "staging"
tag_and_push_image "${AWS_REGION}" "${REPO_NAME_NGINX}" "${image_tag}" "staging"

sed -i "s#wovnrb:latest#"${REPO_NAME_WOVNRB}":"${image_tag}"#g" ${PROJECT_DIR}/docker/scripts/jenkins/taskdef.json
sed -i "s#wovnrb-nginx:latest#"${REPO_NAME_NGINX}":"${image_tag}"#g" ${PROJECT_DIR}/docker/scripts/jenkins/taskdef.json

cd ${PROJECT_DIR}/docker/scripts/jenkins/
TASKDEF_REVISION=$(aws ecs register-task-definition \
                         --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
                         --cli-input-json file://$(pwd)/taskdef.json \
                      | jq ."taskDefinition.revision")
echo "${TASKDEF_REVISION}"

echo "Start ECS Rolling deploy. Update ${ECS_SERVICE_NAME} by ${TASKDEF_FAMILY_NAME}:${TASKDEF_REVISION}"
    aws ecs update-service \
      --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
      --cluster "${CLUSTER_NAME}" \
      --service "${ECS_SERVICE_NAME}" \
      --task-definition "${TASKDEF_FAMILY_NAME}:${TASKDEF_REVISION}"

cd -
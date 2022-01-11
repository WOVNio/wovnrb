#!/usr/bin/env bash
set -eux
export AWS_PROFILE="wovn-code-staging-pipeline"
export AWS_REGION="us-west-2"
export ECR_HOST="257024234524.dkr.ecr.us-west-2.amazonaws.com"
export REPO_NAME="wovnrb"
PROJECT_DIR=$(dirname "$0")/../..

commit_hash=$(git rev-parse --short HEAD)
image_tag="${commit_hash}"

docker build ${PROJECT_DIR}/docker/rails \
             -t "${REPO_NAME}":"${image_tag}"

source tag_and_push_image.sh

# login docker to ECR repository (DO NOT LOG COMMAND INCLUDING TOKEN)
set +x
$(aws ecr get-login --no-include-email --region "${AWS_REGION}" --profile "${AWS_PROFILE}")
set -x

tag_and_push_image "${AWS_REGION}" "${SERVICE_NAME}" "${image_tag}" "staging" &

sed -i "s#<PLACEHOLDER_IMAGE_NAME>#"${ECR_HOST}"/${REPO_NAME}:"${image_tag}"#g" taskdef.json
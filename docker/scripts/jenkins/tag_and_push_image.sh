#!/usr/bin/env bash

# Tag to docker image and push it to specified ECR
#
# Required environment variables:
#  - AWS_PROFILE (AWS profile authorized for ECR login and S3 release)
#
# Args:
#  - region: ECR region (e.g. us-west-1 | us-west-2 )
#  - image-name: docker image name (e.g. equalizer-nginx)
#  - tag: docker image tag. we use git commit hash ordinary (git rev-parse --short HEAD)

tag_and_push_image() {
  local aws_region="${1}"
  local image_name="${2}"
  local tag="${3}"
  local account="${4}"

  if [ ${account} == "production" ]; then
    local ecr_host="140249473629.dkr.ecr.${aws_region}.amazonaws.com"
  elif [ ${account} == "staging" ]; then
    local ecr_host="257024234524.dkr.ecr.${aws_region}.amazonaws.com"
  else
    echo "Passed account not recognized"
    local ecr_host=""
  fi

  docker tag ${image_name}:${tag} ${ecr_host}/${image_name}:${tag}
  docker push ${ecr_host}/${image_name}:${tag}
}
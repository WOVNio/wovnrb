#!/usr/bin/env bash
set -eux

TAG=$1
cd $(dirname $0)
docker build -t "${TAG}" .
cd -
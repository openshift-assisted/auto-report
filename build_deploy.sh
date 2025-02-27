#!/bin/bash

set -exu

TAG=$(git rev-parse HEAD)
SHORT_TAG=$(git rev-parse --short=7 HEAD)
REPO="quay.io/app-sre/auto-report"
export AUTO_REPORT_IMAGE="${REPO}:${TAG}"
export AUTO_REPORT_IMAGE_SHORT_TAG="${REPO}:${SHORT_TAG}"
export CONTAINER_BUILD_EXTRA_PARAMS="--no-cache"
export DOCKER_BUILDKIT=1

make build-image

DOCKER_CONF="$PWD/assisted/.docker"
mkdir -p "$DOCKER_CONF"
docker --config="$DOCKER_CONF" login -u="${QUAY_USER}" -p="${QUAY_TOKEN}" quay.io
docker tag "${AUTO_REPORT_IMAGE}" "${AUTO_REPORT_IMAGE_SHORT_TAG}"
docker tag "${AUTO_REPORT_IMAGE}" "${REPO}:latest"
docker --config="$DOCKER_CONF" push "${AUTO_REPORT_IMAGE}"
docker --config="$DOCKER_CONF" push "${AUTO_REPORT_IMAGE_SHORT_TAG}"
docker --config="$DOCKER_CONF" push "${REPO}:latest"

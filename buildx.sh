#!/bin/bash

REPO=mikenye
IMAGE=flightairmap
PLATFORMS="linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"

set -e

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build the image using buildx
docker buildx build -t "${REPO}/${IMAGE}:latest" --no-cache --compress --push --platform "${PLATFORMS}" .
docker pull "${REPO}/${IMAGE}:latest"

VERSION=$(docker run --rm --entrypoint cat "${REPO}/${IMAGE}:latest" /VERSION | cut -c1-14)

docker buildx build -t "${REPO}/${IMAGE}:${VERSION}" --compress --push --platform "${PLATFORMS}" .

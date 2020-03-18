#!/bin/bash

set -x

IMAGE=mikenye/flightairmap

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build the image using buildx
docker buildx build -t ${IMAGE}:latest --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64 .
docker pull ${IMAGE}:latest

VERSION=$(docker run --rm --entrypoint cat mikenye/flightairmap:latest /VERSION | cut -c1-14)

docker buildx build -t ${IMAGE}:${VERSION} --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64 .

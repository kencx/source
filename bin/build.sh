#!/usr/bin/env bash

set -euo pipefail

PUBLISH_DIR="${1:-./public}"
HUGO_DOCKER_VERSION="0.111.3-ext-alpine"
HUGO_DOCKER_IMAGE="klakegg/hugo:${HUGO_DOCKER_VERSION}"
HUGO_DOCKER="docker run --rm -it -v $(pwd):/src -v $PUBLISH_DIR:/src/public $HUGO_DOCKER_IMAGE"

$HUGO_DOCKER --gc --minify --enableGitInfo

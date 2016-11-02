#!/usr/bin/env bash
# parse-docker-tag-to-use.bash -- Parses the -t/-T arguments and sets DOCKER_IMAGE_TAG_FOR_BRANCH and DOCKER_IMAGE_TAG
##
set -euo pipefail

: ${DOCKER_IMAGE_TAG_FOR_BRANCH:=}
: ${DOCKER_IMAGE_TAG:=}

while getopts "t:T:" o; do
    case $o in
        t) DOCKER_IMAGE_TAG_FOR_BRANCH=$OPTARG ;;
        T) DOCKER_IMAGE_TAG=$OPTARG ;;
    esac
done

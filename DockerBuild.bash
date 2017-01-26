## common configuration for DockerBuild scripts

# call other scripts by name
Here=$(cd "$(dirname "$BASH_SOURCE")" && pwd)
PATH="$Here/util:$Here:$PATH"

# load configuration in DockerBuild.conf
! [[ -r "$Here".conf ]] || . "$Here".conf

# default values
: ${DOCKER_HOST_MOUNTPOINT:="/mnt"}
: ${DOCKER_HOST_PATH:="$(dirname "$Here")"}
: ${DOCKER_CONTAINER:="$(basename "$DOCKER_HOST_PATH" | sanitize-docker-container-name)-build"}
: ${DOCKER_IMAGE:="$USER/$DOCKER_CONTAINER"} # Docker Hub image name for running builds and tests
: ${DOCKER_IMAGE_TAG_STABLE:="latest"}       # tag name for the latest stable build that passed the test
: ${DOCKER_IMAGE_TAG_BUILD:="latest-build"}  # tag name for the latest build
: ${DOCKER_IMAGE_TAG_TEST:="latest-test"}    # tag name for the latest test
: ${DOCKER_IMAGE_TAG_RUN:="latest-run"}      # tag name for the latest build or test
type docker-image-tag-for-branch &>/dev/null || docker-image-tag-for-branch() {
    local branch=$1 tagForBranch=$2
    echo "$branch.$tagForBranch"
}
: ${DOCKER_RUN_OPTS:=}

# default build and test commands (should be quoted)
: ${DOCKER_BUILD_COMMAND:='make -j'}
: ${DOCKER_TEST_COMMAND:='make -j test'}

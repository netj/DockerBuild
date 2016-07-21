# DockerBuild: Containerized builds/tests made easy

Containerized builds and tests can simplify the setup for software development quite significantly.
Each build and test can be isolated from each other, and can be run/rerun/debugged by different people across machines and platforms, and easily reproduce errors found on a cloud CI service from developer's workstation.
DockerBuild provides several commands developers can use to quickly run their builds/tests in [Docker](https://docker.io) containers.

Prerequisites/Assumptions:
1. Obviously, the software should clearly define its *build* and *test* steps, e.g., in executable scripts.
2. The software should use Git.
3. There should be a Docker image built by an existing `Dockerfile` that defines the environment where the software will be built and tested. (`WORKDIR` must be a working copy of its git clone.)

Simply using a `Dockerfile` that builds a container image from scratch for building and testing is not suitable for iterative development in many cases.
Typical `docker build` wastes too much time on repeating all steps that rarely change to ensure build/runtime dependencies, etc.
Imagine redoing an entire `docker build` from the step of cloning the git repo every time you change a single line of code.
DockerBuild proposes a faster development workflow using an already published Docker image that holds a relatively recent build.
After applying the source code changes to the image, an incremental build on top of it can be done much more quickly.
[DeepDive](https://github.com/HazyResearch/deepdive)'s development image [`netj/deepdive-build`](https://hub.docker.com/r/netj/deepdive-build/) is a good example.

Scripts here support the typical build and test tasks using the published image as well as creating and updating it.

## Build/Test

### `build-in-container`
Builds any changes made from the host inside a container using the `latest` image.
A different image can be specified in `DockerBuild.conf`, `DOCKER_IMAGE` environment variable, or a tag as the first argument to the command.

### `test-in-container`
Runs tests against the latest build inside a container.
It commits the container as a image tagged either `latest-test-PASS` or `latest-test-FAIL` with and without the git branch as a prefix for the tag.

There are a few more scripts that launch other containers such as databases and run tests in containers linked to them.

* `test-in-container-postgres`
* `test-in-container-greenplum`

After a successful test, the `latest` image for the current git branch is automatically updated to the build which was used for running the tests.

### `inspect-container`
Starts an interactive shell or runs given command for inspecting the container holding the latest build or test results.
A tag for the container image (also overridable through `DOCKER_IMAGE` environment) to inspect can be specified as the first command line argument.

## Update Images

### `update-latest-image`
Makes the most recent build the new `latest` image, so subsequent `build-in-container` on different branches can start builds on top of it.
This script does not push the image to DockerHub, and should be done manually if desired:

```bash
# after updating latest image locally
update-latest-image

# also publish it
docker push netj/deepdive-build
```

### `rebuild-latest-image-from-scratch`
Uses the `Dockerfile` at the top of the source tree to rebuild the latest image from scratch and pushes to DockerHub.


## Clean up

Scripts here leaves each build and test in a new container image layer, which are kept as small as possible, but still can add up to a huge amount of wasted space.
Here are some tricks to clean them up.

```bash
# to kill and remove all containers
docker ps -qa | xargs docker rm -f

# to remove all images
docker images -qa | xargs docker rmi -f
```

### Garbage collect images
After many builds and tests, many Docker images will show up as having `<none>` REPOSITORY or TAG.
Here's a trick to clean those garbages:
```bash
docker images -q --filter 'dangling=true' | xargs docker rmi -f
```

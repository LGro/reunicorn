#!/usr/bin/env bash
# Build a Reunicorn release APK in Docker, with no host toolchain beyond Docker
# itself and no need to clone veilid separately.
#
#   ./docker/build-apk.sh                 # build the APK
#   ./docker/build-apk.sh test            # run the test suite instead
#   ./docker/build-apk.sh shell           # interactive shell in the build env
#
# Environment:
#   REUNICORN_MAPTILER_TOKEN   passed through as --dart-define (optional; without
#                              it address search and geocoding are inactive)
#   VEILID_SRC                 path to a local veilid checkout to use instead of
#                              the pinned one baked into the image
#   IMAGE                      image tag to build/use (default reunicorn-build:local)
#   NO_BUILD=1                 skip `docker build` and use an existing image
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE="${IMAGE:-reunicorn-build:local}"

# shellcheck source=versions.env
source "${SCRIPT_DIR}/versions.env"

if [ "${NO_BUILD:-0}" != "1" ]; then
    echo "==> Building ${IMAGE} (first run downloads the full toolchain; later runs are cached)"
    docker build \
        --build-arg "FLUTTER_VERSION=${FLUTTER_VERSION}" \
        --build-arg "JAVA_VERSION=${JAVA_VERSION}" \
        --build-arg "RUST_VERSION=${RUST_VERSION}" \
        --build-arg "ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION}" \
        --build-arg "ANDROID_PLATFORM_VERSIONS=${ANDROID_PLATFORM_VERSIONS}" \
        --build-arg "ANDROID_BUILD_TOOLS_VERSIONS=${ANDROID_BUILD_TOOLS_VERSIONS}" \
        --build-arg "ANDROID_CMAKE_VERSIONS=${ANDROID_CMAKE_VERSIONS}" \
        --build-arg "ANDROID_CMDLINE_TOOLS_VERSION=${ANDROID_CMDLINE_TOOLS_VERSION}" \
        --build-arg "VEILID_REPO=${VEILID_REPO}" \
        --build-arg "VEILID_REF=${VEILID_REF}" \
        -t "${IMAGE}" \
        "${SCRIPT_DIR}"
fi

run_args=(
    --rm
    -v "${REPO_DIR}:/workspaces/reunicorn"
    -e "HOST_UID=$(id -u)"
    -e "HOST_GID=$(id -g)"
)

# Keep the Gradle and pub caches across runs so a rebuild is not a redownload.
docker volume inspect reunicorn-gradle-cache >/dev/null 2>&1 || docker volume create reunicorn-gradle-cache >/dev/null
run_args+=( -v reunicorn-gradle-cache:/opt/gradle-home )

if [ -n "${VEILID_SRC:-}" ]; then
    veilid_abs="$(cd "${VEILID_SRC}" && pwd)"
    echo "==> Using local veilid checkout: ${veilid_abs}"
    run_args+=( -v "${veilid_abs}:/workspaces/veilid" )
fi

for var in REUNICORN_MAPTILER_TOKEN REUNICORN_PUSH_BRIDGE_ROUTE LOG_TRACE; do
    [ -n "${!var:-}" ] && run_args+=( -e "${var}" )
done

[ -t 0 ] && run_args+=( -it )

exec docker run "${run_args[@]}" "${IMAGE}" "${@:-build-apk}"

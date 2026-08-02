# Reunicorn Android build environment.
#
# Drives three things from one definition: CI, local "build from source" APK
# builds, and the VS Code devcontainer. Default versions live in
# docker/versions.env; build-apk.sh and CI pass them as --build-arg, and
# docker/check-versions.sh keeps the ARG defaults below in step with that file.
#
# Layout note: /workspaces/<name> is not cosmetic. VS Code mounts a devcontainer
# workspace at /workspaces/<repo-basename>, so putting veilid at
# /workspaces/veilid makes pubspec.yaml's `path: ../veilid/veilid-flutter`
# resolve identically in CI, in a plain `docker run`, and in the devcontainer.
#
# The platform is pinned deliberately, not by accident: Google ships the Android
# command-line tools and the NDK for linux-x86_64 only, so this image cannot be
# arm64. On CI that is a no-op; on an Apple Silicon machine it means the build
# runs under emulation, which works but is noticeably slower.
FROM --platform=linux/amd64 ubuntu:24.04

# The base image ships no generated locales. C.UTF-8 always exists and needs no
# locale-gen, which is what keeps `setlocale` warnings out of every build log.
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Several steps below rely on pipefail and other bashisms; the default RUN shell
# is dash, which has neither.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG JAVA_VERSION=21

# System libraries. This list mirrors APT_LIBS in veilid's own
# dev-setup/setup_linux.sh, which is the authoritative statement of what
# veilid-core + veilid-flutter need to compile.
#
# capnproto is deliberately absent: veilid checks in its generated capnp Rust, so
# `capnp` is only needed when .capnp sources change (veilid's own --build-only
# mode skips it for exactly this reason).
#
# cmake is the host one, needed by the Rust build that `flutter test` triggers.
# It is distinct from the Android SDK's cmake installed further down, which
# Gradle finds through ANDROID_HOME rather than PATH.
RUN apt-get -qq update \
    && apt-get -q install -y --no-install-recommends \
        build-essential pkg-config \
        libssl-dev openssl \
        libdbus-1-dev libdbus-glib-1-dev \
        libgirepository1.0-dev libcairo2-dev libgtk-3-dev \
        liblzma-dev libsecret-1-0 \
        clang llvm file cmake \
        git curl unzip xz-utils jq ca-certificates \
        python3-minimal \
        "openjdk-${JAVA_VERSION}-jdk-headless" \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64

# ---------------------------------------------------------------------------
# Flutter
# ---------------------------------------------------------------------------
ARG FLUTTER_VERSION=3.44.8
ENV FLUTTER_HOME=/opt/flutter \
    PUB_CACHE=/opt/pub-cache
ENV PATH="${FLUTTER_HOME}/bin:${PUB_CACHE}/bin:${PATH}"

# The SDK is a git checkout owned by a different uid than the one using it, so
# without the safe.directory entry every flutter invocation dies on "dubious
# ownership" — the failure this whole containerisation started from.
RUN curl --proto '=https' --tlsv1.2 -fsSL \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        -o /tmp/flutter.tar.xz \
    && tar -xJf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz \
    && git config --global --add safe.directory "${FLUTTER_HOME}" \
    && flutter config --no-analytics \
    && dart --disable-analytics \
    && flutter --version

# ---------------------------------------------------------------------------
# Android SDK
# ---------------------------------------------------------------------------
ARG ANDROID_CMDLINE_TOOLS_VERSION=13114758
ARG ANDROID_PLATFORM_VERSIONS="35 36"
ARG ANDROID_BUILD_TOOLS_VERSIONS="35.0.0 36.0.0"
ARG ANDROID_NDK_VERSION=28.2.13676358
ARG ANDROID_CMAKE_VERSIONS="3.22.1 4.0.2"

ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    GRADLE_USER_HOME=/opt/gradle-home
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

RUN curl --proto '=https' --tlsv1.2 -fsSL \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" \
        -o /tmp/cmdline-tools.zip \
    && mkdir -p "${ANDROID_HOME}/cmdline-tools" \
    && unzip -q /tmp/cmdline-tools.zip -d "${ANDROID_HOME}/cmdline-tools" \
    && mv "${ANDROID_HOME}/cmdline-tools/cmdline-tools" "${ANDROID_HOME}/cmdline-tools/latest" \
    && rm /tmp/cmdline-tools.zip

# `yes` takes SIGPIPE when sdkmanager closes the pipe first, so the licence
# acceptance runs in a subshell with pipefail off; otherwise that signal would
# mask sdkmanager's real exit status. ANDROID_PLATFORM_VERSIONS is intentionally
# unquoted when expanded into the package list — it is a space-separated set.
#
# The install output is NOT silenced: sdkmanager reports an unknown package as a
# one-line "Warning: Failed to find package ..." and then exits non-zero, so
# suppressing stdout leaves a build failure with no stated cause.
RUN set -eu; \
    ( set +o pipefail; yes | sdkmanager --licenses > /dev/null ); \
    packages=("platform-tools" "ndk;${ANDROID_NDK_VERSION}"); \
    for v in ${ANDROID_PLATFORM_VERSIONS}; do packages+=("platforms;android-${v}"); done; \
    for v in ${ANDROID_BUILD_TOOLS_VERSIONS}; do packages+=("build-tools;${v}"); done; \
    for v in ${ANDROID_CMAKE_VERSIONS}; do packages+=("cmake;${v}"); done; \
    sdkmanager --install "${packages[@]}"

# ---------------------------------------------------------------------------
# Rust
# ---------------------------------------------------------------------------
# Pinned to an exact version rather than a channel: veilid-flutter builds through
# native_toolchain_rust, which rejects stable/beta/nightly outright.
ARG RUST_VERSION=1.92.0
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
ENV PATH="${CARGO_HOME}/bin:${PATH}"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --no-modify-path --profile minimal \
              --default-toolchain "${RUST_VERSION}" \
    && rustup target add \
        aarch64-linux-android \
        armv7-linux-androideabi \
        i686-linux-android \
        x86_64-linux-android \
    && chmod -R a+w "${CARGO_HOME}" "${RUSTUP_HOME}" \
    && rustc --version

# Bind-mounted repositories are owned by the host uid, so git inside the
# container sees them as untrusted.
RUN git config --global --add safe.directory '*'

RUN flutter precache --android

# ---------------------------------------------------------------------------
# Veilid  (last: bumping VEILID_REF must not invalidate the toolchain layers)
# ---------------------------------------------------------------------------
ARG VEILID_REPO=https://gitlab.com/veilid/veilid.git
ARG VEILID_REF=76b2176926dc24e30f9427540384a04ae22e590c

# init + fetch rather than `clone --depth 1`, because --depth 1 cannot check out
# an arbitrary commit; this form accepts either a tag or a full SHA.
RUN mkdir -p /workspaces/veilid \
    && cd /workspaces/veilid \
    && git init -q \
    && git remote add origin "${VEILID_REPO}" \
    && git fetch -q --depth 1 origin "${VEILID_REF}" \
    && git checkout -q --detach FETCH_HEAD \
    && git --no-pager log -1 --format='veilid pinned at %H'

# Gradle's file-system watching uses inotify, which does not work through a
# bind mount (notably Docker Desktop on macOS). Left on, it throws
# "Couldn't poll for events, error = 4" mid-build — noisy but harmless, since
# Gradle falls back and continues. Off, because a one-shot container build has
# nothing to gain from watching. The daemon is disabled for the same reason:
# nothing outlives the container, so it only costs memory.
ENV GRADLE_OPTS="-Dorg.gradle.vfs.watch=false -Dorg.gradle.daemon=false"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspaces/reunicorn
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["build-apk"]

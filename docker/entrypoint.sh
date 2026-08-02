#!/usr/bin/env bash
# Entrypoint for the Reunicorn build container.
#
#   test       flutter pub get && flutter test
#   build-apk  flutter pub get && flutter build apk --release
#   analyze    flutter analyze
#   shell      interactive bash (devcontainer / debugging)
#
# Anything else is executed verbatim, so `docker run <image> flutter doctor -v`
# works too.
set -euo pipefail

APP_DIR=/workspaces/reunicorn

# Only the subcommands that operate on the app need the bind mount; passthrough
# commands like `flutter doctor -v` are useful without one.
require_app_dir() {
    if [ ! -f "${APP_DIR}/pubspec.yaml" ]; then
        cat >&2 <<EOF
error: no pubspec.yaml at ${APP_DIR}

The repository must be bind-mounted there, e.g.
    docker run --rm -v "\$PWD:${APP_DIR}" <image> build-apk
EOF
        exit 1
    fi
}

cd "${APP_DIR}" 2>/dev/null || cd /

# Compile-time configuration. REUNICORN_MAPTILER_TOKEN and friends are read via
# String.fromEnvironment, so they must be passed as --dart-define at build time;
# an ordinary environment variable has no effect on the built app.
dart_defines=()
define_names=()
while IFS= read -r var; do
    [ -n "${!var:-}" ] || continue
    dart_defines+=("--dart-define=${var}=${!var}")
    define_names+=("${var}")
done < <(compgen -v | grep -E '^(REUNICORN_|LOG_TRACE$)' | sort || true)

# Names only — the values are tokens.
if [ ${#define_names[@]} -gt 0 ]; then
    printf 'dart-defines: %s\n' "${define_names[*]}" >&2
else
    printf 'dart-defines: none (REUNICORN_MAPTILER_TOKEN unset; address search will be inactive)\n' >&2
fi

# Size the Gradle JVM to the container, not to the host. android/gradle.properties
# sets -Xmx4096m, which is sensible on a dev machine but larger than a default
# Docker Desktop VM gives a container — so Gradle alone could exceed the cgroup
# before the Rust cross-compiles even start, and the container died with a bare
# "unexpected EOF". A -D on the command line overrides gradle.properties.
mem_bytes=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)
if [ "${mem_bytes}" = "max" ] || [ -z "${mem_bytes}" ]; then
    mem_bytes=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) * 1024 ))
fi
mem_mb=$(( mem_bytes / 1024 / 1024 ))
# A third, not a half: Gradle is not the only tenant. The APK build compiles
# veilid for four Android ABIs, and those rustc/lld processes run alongside the
# Gradle JVM. Giving Gradle half of a 7.7GB VM produced -Xmx3968m and the daemon
# was OOM-killed ~35 minutes in ("Gradle build daemon disappeared unexpectedly").
heap_mb=$(( mem_mb / 3 ))
[ "${heap_mb}" -gt 3072 ] && heap_mb=3072
[ "${heap_mb}" -lt 1024 ] && heap_mb=1024
export GRADLE_OPTS="${GRADLE_OPTS:-} -Dorg.gradle.jvmargs=-Xmx${heap_mb}m"

# Cap the other side of the same budget. Without this, cargo fans out to one job
# per core (8 here) and the peak overlaps with Gradle's heap.
if [ -z "${CARGO_BUILD_JOBS:-}" ]; then
    jobs=$(( mem_mb / 2048 ))
    [ "${jobs}" -lt 1 ] && jobs=1
    [ "${jobs}" -gt "$(nproc)" ] && jobs=$(nproc)
    export CARGO_BUILD_JOBS="${jobs}"
fi

if [ "${mem_mb}" -lt 6144 ]; then
    cat >&2 <<EOF
warning: only ${mem_mb}MB of memory available to this container.
         Building the Android APK compiles veilid for four ABIs alongside a
         Gradle JVM; below ~6GB the container can be OOM-killed, which surfaces
         as "error waiting for container: unexpected EOF" with no other cause.
         Raise Docker Desktop's memory limit (Settings -> Resources) if that happens.
EOF
fi

# Flutter regenerates these with absolute paths pointing inside the container
# (/opt/flutter, /opt/android-sdk, /opt/pub-cache). Through a bind mount that
# overwrites the host's copies, so a container build silently breaks the next
# host-side `flutter run` until the developer regenerates them. Snapshot them
# and put them back on the way out.
HOST_STATE=(android/local.properties .flutter-plugins-dependencies .dart_tool/package_config.json)
SNAPSHOT_DIR=$(mktemp -d)
snapshot_host_state() {
    local f
    for f in "${HOST_STATE[@]}"; do
        [ -f "${f}" ] || continue
        mkdir -p "${SNAPSHOT_DIR}/$(dirname "${f}")"
        cp -p "${f}" "${SNAPSHOT_DIR}/${f}"
    done
}
restore_host_state() {
    local f
    for f in "${HOST_STATE[@]}"; do
        [ -f "${SNAPSHOT_DIR}/${f}" ] || continue
        cp -p "${SNAPSHOT_DIR}/${f}" "${f}" 2>/dev/null || true
    done
    rm -rf "${SNAPSHOT_DIR}"
}

# Hand bind-mounted artifacts back to the invoking user. Without this, `build/`
# and `.dart_tool/` end up root-owned on Linux hosts and the next host-side
# flutter command fails.
restore_ownership() {
    [ -n "${HOST_UID:-}" ] && [ -n "${HOST_GID:-}" ] || return 0
    chown -R "${HOST_UID}:${HOST_GID}" \
        build .dart_tool .flutter-plugins-dependencies pubspec.lock android/local.properties 2>/dev/null || true
}

on_exit() {
    restore_host_state
    restore_ownership
}
trap on_exit EXIT

case "${1:-build-apk}" in
    # These deliberately do not exec: exec would replace the shell and skip the
    # EXIT trap that hands artifacts back to the host user.
    test)
        require_app_dir
        snapshot_host_state
        shift
        flutter pub get
        flutter test "$@"
        ;;
    analyze)
        require_app_dir
        snapshot_host_state
        shift
        flutter pub get
        flutter analyze "$@"
        ;;
    build-apk)
        require_app_dir
        snapshot_host_state
        shift
        flutter pub get
        flutter build apk --release "${dart_defines[@]}" "$@"
        echo
        echo "APK: ${APP_DIR}/build/app/outputs/flutter-apk/app-release.apk"
        ;;
    shell)
        exec bash
        ;;
    *)
        exec "$@"
        ;;
esac

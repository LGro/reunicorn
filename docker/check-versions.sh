#!/usr/bin/env bash
# Verify docker/versions.env against the places that actually decide each version.
#
# This exists because toolchain drift here is silent: Gradle auto-downloads the
# platform and build-tools it needs, and native_toolchain_rust reads its own
# rust-toolchain.toml, so a wrong pin costs build time and reproducibility
# without ever failing loudly. The workflow ran with platforms;android-29 against
# compileSdkVersion 37, and installed Android targets on the stable Rust channel
# while the build used a pinned 1.92.0, for exactly this reason.
#
# Checks against ../veilid (or /workspaces/veilid) are skipped when no checkout
# is present, so this stays usable on a bare clone.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${SCRIPT_DIR}/versions.env"

VEILID_DIR=""
for candidate in /workspaces/veilid "${REPO_DIR}/../veilid"; do
    [ -d "${candidate}/veilid-flutter" ] && { VEILID_DIR="$(cd "${candidate}" && pwd)"; break; }
done

fail=0
ok()   { printf '  \033[32mok\033[0m    %-26s %s\n' "$1" "$2"; }
bad()  { printf '  \033[31mFAIL\033[0m  %-26s %s\n' "$1" "$2"; fail=1; }
skip() { printf '  --    %-26s %s\n' "$1" "$2"; }

# check <label> <expected> <actual> <source>
check() {
    local label="$1" expected="$2" actual="$3" source="$4"
    if [ -z "${actual}" ]; then
        skip "${label}" "could not read from ${source}"
    elif [ "${expected}" = "${actual}" ]; then
        ok "${label}" "${actual}  (${source})"
    else
        bad "${label}" "versions.env has '${expected}', ${source} says '${actual}'"
    fi
}

echo "Checking docker/versions.env against the tree..."

# --- Flutter: .fvmrc ---
check "FLUTTER_VERSION" "${FLUTTER_VERSION}" \
    "$(grep -oE '"flutter"[[:space:]]*:[[:space:]]*"[^"]+"' "${REPO_DIR}/.fvmrc" 2>/dev/null | grep -oE '[0-9][^"]*')" \
    ".fvmrc"

# --- Java + NDK + compileSdk: android/app/build.gradle ---
GRADLE="${REPO_DIR}/android/app/build.gradle"
check "JAVA_VERSION" "${JAVA_VERSION}" \
    "$(grep -oE "jvmTarget[[:space:]]*=[[:space:]]*'[0-9]+'" "${GRADLE}" 2>/dev/null | grep -oE '[0-9]+')" \
    "android/app/build.gradle jvmTarget"

check "ANDROID_NDK_VERSION" "${ANDROID_NDK_VERSION}" \
    "$(grep -oE 'ndkVersion[[:space:]]+"[^"]+"' "${GRADLE}" 2>/dev/null | grep -oE '[0-9][^"]*')" \
    "android/app/build.gradle ndkVersion"

# From API 37 the sdkmanager packages are minor-versioned ("android-37.0"), so a
# compileSdkVersion of 37 is satisfied by 37 or by any 37.x.
compile_sdk="$(grep -oE 'compileSdkVersion[[:space:]]+[0-9]+' "${GRADLE}" 2>/dev/null | grep -oE '[0-9]+')"
if [ -z "${compile_sdk}" ]; then
    skip "ANDROID_PLATFORM_VERSIONS" "could not read compileSdkVersion"
else
    matched=""
    for v in ${ANDROID_PLATFORM_VERSIONS}; do
        if [ "${v}" = "${compile_sdk}" ] || [ "${v%%.*}" = "${compile_sdk}" ]; then
            matched="${v}"
            break
        fi
    done
    if [ -n "${matched}" ]; then
        ok "ANDROID_PLATFORM_VERSIONS" "compileSdkVersion ${compile_sdk} -> android-${matched}"
    else
        bad "ANDROID_PLATFORM_VERSIONS" "compileSdkVersion ${compile_sdk} is not in '${ANDROID_PLATFORM_VERSIONS}'"
    fi
fi

# --- Rust + veilid's own pins ---
if [ -z "${VEILID_DIR}" ]; then
    skip "RUST_VERSION" "no veilid checkout found; skipping veilid cross-checks"
else
    check "RUST_VERSION" "${RUST_VERSION}" \
        "$(grep -oE 'channel[[:space:]]*=[[:space:]]*"[^"]+"' "${VEILID_DIR}/veilid-flutter/rust/rust-toolchain.toml" 2>/dev/null | grep -oE '[0-9][^"]*')" \
        "veilid rust-toolchain.toml"

    VERSIONS_ENV="${VEILID_DIR}/.dagger/versions.env"
    if [ -f "${VERSIONS_ENV}" ]; then
        veilid_val() { grep -oE "^$1=\"[^\"]*\"" "${VERSIONS_ENV}" 2>/dev/null | cut -d'"' -f2; }

        # A list, and veilid's pin is a floor rather than an equality: AGP 8.13
        # needs 36.0.0 for reunicorn while plugin modules still ask for 35.0.0,
        # and veilid pins 35.0.0. Both are installed so neither is downloaded
        # mid-build; the newest of ours must clear veilid's floor.
        veilid_bt="$(veilid_val ANDROID_BUILD_TOOLS_VERSION)"
        newest_bt="$(printf '%s\n' ${ANDROID_BUILD_TOOLS_VERSIONS} | sort -V | tail -1)"
        if [ -n "${veilid_bt}" ]; then
            lowest="$(printf '%s\n%s\n' "${newest_bt}" "${veilid_bt}" | sort -V | head -1)"
            if [ "${lowest}" = "${veilid_bt}" ]; then
                ok "BUILD_TOOLS >= veilid min" "${newest_bt} >= ${veilid_bt}"
            else
                bad "BUILD_TOOLS >= veilid min" "${newest_bt} < veilid's ${veilid_bt}"
            fi
        fi

        # A list: veilid's pin must be present, and so must 3.22.1, which AGP
        # installs by default for veilid-flutter's externalNativeBuild when the
        # module names no version. Both are pinned so neither is fetched mid-build.
        veilid_cmake="$(veilid_val ANDROID_CMAKE_VERSION)"
        for required in ${veilid_cmake} 3.22.1; do
            if [[ " ${ANDROID_CMAKE_VERSIONS} " == *" ${required} "* ]]; then
                ok "ANDROID_CMAKE_VERSIONS" "includes ${required}"
            else
                bad "ANDROID_CMAKE_VERSIONS" "missing ${required} (have '${ANDROID_CMAKE_VERSIONS}')"
            fi
        done
        check "ANDROID_CMDLINE_TOOLS_VERSION" "${ANDROID_CMDLINE_TOOLS_VERSION}" \
            "$(veilid_val ANDROID_CMDLINE_TOOLS_VERSION)" "veilid versions.env"

        # Flutter and Java are floors on veilid's side, not equalities: reunicorn
        # legitimately runs ahead of both.
        veilid_flutter_min="$(veilid_val FLUTTER_MIN_VERSION)"
        if [ -n "${veilid_flutter_min}" ]; then
            lowest="$(printf '%s\n%s\n' "${FLUTTER_VERSION}" "${veilid_flutter_min}" | sort -V | head -1)"
            if [ "${lowest}" = "${veilid_flutter_min}" ]; then
                ok "FLUTTER_VERSION >= veilid min" "${FLUTTER_VERSION} >= ${veilid_flutter_min}"
            else
                bad "FLUTTER_VERSION >= veilid min" "${FLUTTER_VERSION} < veilid's ${veilid_flutter_min}"
            fi
        fi

        veilid_java_min="$(veilid_val JAVA_MIN_VERSION)"
        if [ -n "${veilid_java_min}" ]; then
            if [ "${JAVA_VERSION}" -ge "${veilid_java_min}" ] 2>/dev/null; then
                ok "JAVA_VERSION >= veilid min" "${JAVA_VERSION} >= ${veilid_java_min}"
            else
                bad "JAVA_VERSION >= veilid min" "${JAVA_VERSION} < veilid's ${veilid_java_min}"
            fi
        fi
    fi

    # The pinned ref must exist in the local checkout for this to mean anything.
    if git -C "${VEILID_DIR}" cat-file -e "${VEILID_REF}^{commit}" 2>/dev/null; then
        ok "VEILID_REF" "$(git -C "${VEILID_DIR}" rev-parse --short "${VEILID_REF}") resolves locally"
    else
        skip "VEILID_REF" "${VEILID_REF:0:12} not in the local veilid checkout (fetch to verify)"
    fi
fi

# --- Dockerfile ARG defaults ---
# The defaults matter on their own: a bare `docker build` and the devcontainer
# both use them without ever reading versions.env.
DOCKERFILE="${SCRIPT_DIR}/Dockerfile"
for key in FLUTTER_VERSION JAVA_VERSION RUST_VERSION ANDROID_NDK_VERSION \
           ANDROID_BUILD_TOOLS_VERSIONS ANDROID_CMAKE_VERSIONS \
           ANDROID_CMDLINE_TOOLS_VERSION ANDROID_PLATFORM_VERSIONS VEILID_REF; do
    default="$(grep -oE "^ARG ${key}=.*$" "${DOCKERFILE}" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"')"
    check "Dockerfile ARG ${key}" "${!key}" "${default}" "Dockerfile default"
done

echo
if [ "${fail}" -ne 0 ]; then
    echo "Version drift detected. Update docker/versions.env (or the source) and re-run." >&2
    exit 1
fi
echo "All pinned versions agree with their sources."

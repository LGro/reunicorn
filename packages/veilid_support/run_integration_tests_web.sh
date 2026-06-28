#!/usr/bin/env bash
# Build the dart-flavored veilid-flutter wasm blob, copy it into the example
# web/wasm directory, and run the veilid_support example integration tests
# against Chrome headless via `flutter drive -d chrome`.
#
# Mirrors the option surface of veilid-wasm/wasm_test_js.sh.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# pipefail keeps pipe exit codes; no `set -e` — failures are handled explicitly
# so this script returns the flutter-drive test result.
set -o pipefail

print_help() {
    cat <<EOF
Usage: $0 [options] [-- flutter-drive args...]

Options:
  --release-build      Build veilid-flutter wasm in release mode (default: debug)
  --tests=LIST         Comma-separated list of test groups to run.
                       If omitted, all groups are enabled. Available:
                         persistent_queue
                         dht
                         table_db
  --verbose-tracing    Enable veilid-core/verbose-tracing cargo feature (rebuilds wasm)
  --debug              Enable LOG_LEVEL=debug for veilid logs.
                       Also forwards \$LOG_DIRECTIVES if set in the shell env.
  --help, -h           Show this help

Env:
  SKIP_WASM_BUILD=1    Skip the wasm rebuild + copy step (dart-only iteration)
  LOG_DIRECTIVES=...   Forwarded as --dart-define=LOG_DIRECTIVES when set
EOF
}

RELEASE_BUILD=0
VERBOSE_TRACING=0
DEBUG=0
TESTS=""
PASSTHROUGH=()
while [ $# -gt 0 ]; do
    case "$1" in
        --release-build)   RELEASE_BUILD=1 ;;
        --tests=*)         TESTS="${1#--tests=}" ;;
        --verbose-tracing) VERBOSE_TRACING=1 ;;
        --debug)           DEBUG=1 ;;
        --help|-h)         print_help; exit 0 ;;
        --)                shift; PASSTHROUGH+=("$@"); break ;;
        *)                 PASSTHROUGH+=("$1") ;;
    esac
    shift
done

DEFINES=()
if [ -z "$TESTS" ]; then
    DEFINES+=(--dart-define=ENABLE_TEST_PERSISTENT_QUEUE=true)
    DEFINES+=(--dart-define=ENABLE_TEST_DHT=true)
    DEFINES+=(--dart-define=ENABLE_TEST_TABLE_DB=true)
else
    IFS=',' read -ra TEST_LIST <<< "$TESTS"
    for t in "${TEST_LIST[@]}"; do
        case "$t" in
            persistent_queue) DEFINES+=(--dart-define=ENABLE_TEST_PERSISTENT_QUEUE=true) ;;
            dht)              DEFINES+=(--dart-define=ENABLE_TEST_DHT=true) ;;
            table_db)         DEFINES+=(--dart-define=ENABLE_TEST_TABLE_DB=true) ;;
            *)
                echo "Unknown test group: $t" >&2
                echo "Available: persistent_queue, dht, table_db" >&2
                exit 1
                ;;
        esac
    done
fi

WASM_BUILD_ARGS=()
if [ "$RELEASE_BUILD" -eq 1 ]; then
    WASM_BUILD_ARGS+=("release")
fi
if [ "$VERBOSE_TRACING" -eq 1 ]; then
    WASM_BUILD_ARGS+=("--features=veilid-core/verbose-tracing")
fi

if [ "$DEBUG" -eq 1 ]; then
    DEFINES+=(--dart-define=LOG_LEVEL=debug)
fi
if [ -n "${LOG_DIRECTIVES:-}" ]; then
    DEFINES+=(--dart-define=LOG_DIRECTIVES="$LOG_DIRECTIVES")
fi

if [ "${SKIP_WASM_BUILD:-0}" != "1" ]; then
    "$SCRIPTDIR/example/dev-setup/wasm_update.sh" "${WASM_BUILD_ARGS[@]}" || { echo "wasm build failed" >&2; exit 1; }
fi

VEILIDDIR="$(cd "$SCRIPTDIR/../../../veilid" && pwd)" || exit 1

# shellcheck disable=SC1091
source "$VEILIDDIR/scripts/_chromedriver_helper.sh"
trap stop_chromedriver EXIT
start_chromedriver || { echo "failed to start chromedriver" >&2; exit 1; }
start_chromedriver_log_poller

pushd "$SCRIPTDIR/example" >/dev/null || exit 1
# -d chrome (NOT -d web-server): integration_test's FlutterDriver protocol
# requires the dart VM service which `-d chrome` exposes; `-d web-server` mode
# silently no-ops test bodies. chromedriver is still needed for the webdriver
# bridge. A Chrome window pops up; `--web-run-headless` would suppress it but
# triggers a Chrome 132+ port-mismatch bug — see flutter#160434 — so leave it
# visible for now. Browser console is forwarded by start_chromedriver_log_poller.
run_flutter_drive_for_web_tests \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/app_test.dart \
    -d chrome \
    --verbose \
    "${DEFINES[@]}" \
    "${PASSTHROUGH[@]}"
status=$?
popd >/dev/null
exit $status

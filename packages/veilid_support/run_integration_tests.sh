#!/bin/bash
pushd example 2>/dev/null

# Default to the #common=debug log tag group unless the caller overrides LOG_DIRECTIVES
case "$*" in
    *LOG_DIRECTIVES*) ;;
    *) set -- --dart-define=LOG_DIRECTIVES='#common=debug' "$@" ;;
esac

flutter test -r github integration_test/app_test.dart "$@"
status=$?
popd 2>/dev/null
exit $status

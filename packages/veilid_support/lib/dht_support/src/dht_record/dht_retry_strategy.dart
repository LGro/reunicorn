part of 'dht_record_pool.dart';

/// Bounded default so an offline DHT op gives up instead of retrying forever.
const kDefaultDHTRetryTimeout = Duration(seconds: 10);

/// DHT-level retry policy: retry the transient DHTExceptions that clear on a
/// later attempt. By default `notAvailable` (often offline) records telemetry
/// then waits for the network via [pool] (default [DHTRecordPool.instance]),
/// falling back to a short delay only when already online; `outdated` (a newer
/// remote value) records telemetry and retries immediately. Both retry until
/// the strategy [timeout] (defaults to [kDefaultDHTRetryTimeout]). Override
/// either action to change the behavior.
class DHTRetryStrategy extends RetryStrategy {
  // ignore: use_super_parameters
  DHTRetryStrategy({
    DHTRecordPool? pool,
    RetryAction? notAvailableRetry,
    RetryAction? outdatedRetry,
    Duration? timeout,
  }) : super(
          rules: [
            RetryRule(
              matches: (e) => e is DHTExceptionNotAvailable,
              beforeRetry: notAvailableRetry ??
                  ((n) => defaultNotAvailableRetry(pool, n)),
            ),
            RetryRule(
              matches: (e) => e is DHTExceptionOutdated,
              beforeRetry: outdatedRetry ?? ((n) => defaultOutdatedRetry(pool, n)),
            ),
          ],
          timeout: timeout ?? kDefaultDHTRetryTimeout,
        );

  /// Same as [DHTRetryStrategy] but logs each retry via the pool logger tagged
  /// with [label], so callers can see how many retries an op needed (a non-zero
  /// count surfaces transient/cold-start conditions). Behavior is unchanged: it
  /// passes through to the supplied or default retry actions.
  factory DHTRetryStrategy.logged(
    String label, {
    DHTRecordPool? pool,
    RetryAction? notAvailableRetry,
    RetryAction? outdatedRetry,
    Duration? timeout,
  }) {
    final p = pool ?? DHTRecordPool.instance;
    return DHTRetryStrategy(
      pool: pool,
      notAvailableRetry: (n) {
        p.log('$label: retry #$n (notAvailable)');
        final action =
            notAvailableRetry ?? ((m) => defaultNotAvailableRetry(pool, m));
        return action(n);
      },
      outdatedRetry: (n) {
        p.log('$label: retry #$n (outdated)');
        final action = outdatedRetry ?? ((m) => defaultOutdatedRetry(pool, m));
        return action(n);
      },
      timeout: timeout,
    );
  }

  /// Record a notAvailable retry, then wait for the network (or a 1s fallback
  /// when already online). Always retries (bounded by the strategy timeout).
  static Future<bool> defaultNotAvailableRetry(
    DHTRecordPool? pool,
    int attemptNumber,
  ) async {
    final p = pool ?? DHTRecordPool.instance;
    p.stats.recordRetry(DHTRetryKind.notAvailable);
    await p.waitReadyOrDelay(const Duration(seconds: 1));
    return true;
  }

  /// Record an outdated retry and retry immediately (bounded by the strategy
  /// timeout).
  static Future<bool> defaultOutdatedRetry(
    DHTRecordPool? pool,
    int attemptNumber,
  ) async {
    (pool ?? DHTRecordPool.instance).stats.recordRetry(DHTRetryKind.outdated);
    return true;
  }
}

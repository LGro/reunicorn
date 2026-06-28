import 'dart:async';

import 'package:async_tools/async_tools.dart';

import '../dht_record/dht_record_pool.dart';

const _kRefreshBackstopInterval = Duration(seconds: 30);
const _sfRefresh = 'sfRefresh';

/// Drives catch-up refreshes for a cubit wrapping a DHT collection. The cubit
/// implements [refresh] and [collectionNeedsRefresh]; the driver calls
/// [refresh] when the collection is behind, on the network offline->online edge
/// and on a slow backstop timer. Refresh attempts are deduplicated.
abstract mixin class RefreshableCubit {
  Future<void> refresh();

  /// Whether the wrapped collection knows it is behind.
  bool get collectionNeedsRefresh;

  Timer? _refreshTimer;
  StreamSubscription<bool>? _refreshEnableSub;

  /// Start the driver once the wrapped collection is open.
  void startRefreshDriver({DHTRecordPool? pool}) {
    final p = pool ?? DHTRecordPool.instance;
    _refreshEnableSub = p.streamRefreshEnable().listen((enabled) {
      if (enabled) {
        _maybeRefresh();
      }
    });
    _refreshTimer = Timer.periodic(_kRefreshBackstopInterval, (_) {
      if (p.refreshEnabled) {
        _maybeRefresh();
      }
    });
  }

  void _maybeRefresh() {
    if (!collectionNeedsRefresh) {
      return;
    }
    singleFuture((this, _sfRefresh), () async {
      if (!collectionNeedsRefresh) {
        return;
      }
      try {
        await refresh();
      } on Exception {
        // refresh logs its own failure; needsRefresh stays true for next trigger
      }
    });
  }

  Future<void> closeRefreshDriver() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await _refreshEnableSub?.cancel();
    _refreshEnableSub = null;
  }
}

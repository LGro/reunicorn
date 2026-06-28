part of 'dht_record_pool.dart';

class _DHTRecordWatchSubscriptionInner implements Finalize {
  // Record this watch is for for reference counting purposes
  final DHTRecord record;

  // Subscription to the record's watch change stream
  final StreamSubscription<DHTRecordWatchChange> subscription;

  // Ensure we never cancel twice
  bool cancelled = false;

  // Debug name
  final String debugName;

  /// Inner constructor for a finalizable watch subscription
  _DHTRecordWatchSubscriptionInner({
    required this.record,
    required this.subscription,
    required this.debugName,
  });

  /// Cancel the subscription
  Future<void> cancel() async {
    try {
      if (cancelled) {
        throw StateError('_DHTRecordWatchSubscriptionInner already cancelled');
      }
      cancelled = true;
      await subscription.cancel();
    } finally {
      await record.close();
    }
  }

  /// Called by finalizer if cancel was forgotten before drop
  @override
  Future<void> finalize() async {
    // Finalize should be drop-safe no matter what
    if (!cancelled) {
      await cancel();
    }
  }
}

/// A subscription to a DHTRecord's watch change stream
/// Must call close() on this stream subscription before dropping it
class DHTRecordWatchSubscription implements DHTCloseable, DebugName {
  DHTRecordWatchSubscription._({
    required DHTRecord record,
    required StreamSubscription<DHTRecordWatchChange> subscription,
    required String debugName,
  }) : _inner = _DHTRecordWatchSubscriptionInner(
         record: record,
         subscription: subscription,
         debugName: debugName,
       ) {
    // Keep a record reference until this subscription is cancelled
    _inner.record.ref();

    // Attach finalizer to ensure things clean up even if the
    // user forgets to close()
    _finalizer.attach(this, _inner, detach: this);
  }

  void pause([Future<void>? resumeSignal]) {
    _inner.subscription.pause(resumeSignal);
  }

  void resume() {
    _inner.subscription.resume();
  }

  bool get isPaused => _inner.subscription.isPaused;

  // DHTCloseable
  ////////////////////////////////////////////////////////////////////////////
  @override
  Future<bool> close() async {
    _finalizer.detach(this);
    await _inner.cancel();
    return true;
  }

  @override
  bool get isOpen => !_inner.cancelled;

  // DebugName
  ////////////////////////////////////////////////////////////////////////////

  @override
  String get debugName => _inner.record.debugName;

  // Fields
  ////////////////////////////////////////////////////////////////////////////

  final _DHTRecordWatchSubscriptionInner _inner;

  /// Asynchronous finalizer registration for the inner object
  static final Finalizer<_DHTRecordWatchSubscriptionInner> _finalizer =
      Finalizer((inner) => inner.record.pool.lateFinalizer(inner));
}

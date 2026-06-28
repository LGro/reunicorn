import 'package:collection/collection.dart';
import 'package:indent/indent.dart';

import '../../../veilid_support.dart';

const maxLatencySamples = 100;
const timeoutDuration = 10;

extension LatencyStatsExt on LatencyStats {
  String debugString() =>
      'fast($fastest)/avg($average)/slow($slowest)/'
      'tm90($tm90)/tm75($tm75)/p90($p90)/p75($p75)';
}

class LatencyStatsAccounting {
  /////////////////////////////
  final int maxSamples;

  final _samples = <TimestampDuration>[];

  LatencyStatsAccounting({required this.maxSamples});

  LatencyStats record(TimestampDuration dur) {
    _samples.add(dur);
    if (_samples.length > maxSamples) {
      _samples.removeAt(0);
    }

    final sortedList = _samples.sorted();

    final fastest = sortedList.first;
    final slowest = sortedList.last;
    final average = TimestampDuration(
      value:
          sortedList.fold(BigInt.zero, (acc, x) => acc + x.value) ~/
          BigInt.from(sortedList.length),
    );

    final tm90len = (sortedList.length * 90 + 99) ~/ 100;
    final tm75len = (sortedList.length * 75 + 99) ~/ 100;
    final tm90 = TimestampDuration(
      value:
          sortedList
              .sublist(0, tm90len)
              .fold(BigInt.zero, (acc, x) => acc + x.value) ~/
          BigInt.from(tm90len),
    );
    final tm75 = TimestampDuration(
      value:
          sortedList
              .sublist(0, tm75len)
              .fold(BigInt.zero, (acc, x) => acc + x.value) ~/
          BigInt.from(tm90len),
    );
    final p90 = sortedList[tm90len - 1];
    final p75 = sortedList[tm75len - 1];

    final ls = LatencyStats(
      fastest: fastest,
      slowest: slowest,
      average: average,
      tm90: tm90,
      tm75: tm75,
      p90: p90,
      p75: p75,
    );

    return ls;
  }
}

class DHTCallStats {
  void record(TimestampDuration dur, Exception? exc) {
    final wasTimeout =
        exc is VeilidAPIExceptionTimeout || dur.toSecs() >= timeoutDuration;

    calls++;
    if (wasTimeout) {
      timeouts++;
    } else {
      successLatency = successLatencyAcct.record(dur);
    }
    latency = latencyAcct.record(dur);
  }

  String debugString() =>
      ' timeouts/calls: $timeouts/$calls (${(timeouts * 100 / calls).toStringAsFixed(3)}%)\n'
      'success latency: ${successLatency?.debugString()}\n'
      '    all latency: ${latency?.debugString()}\n';

  /////////////////////////////

  // lint conflict
  // ignore: omit_obvious_property_types
  int calls = 0;
  // lint conflict
  // ignore: omit_obvious_property_types
  int timeouts = 0;
  LatencyStats? latency;
  LatencyStats? successLatency;
  final latencyAcct = LatencyStatsAccounting(maxSamples: maxLatencySamples);
  final successLatencyAcct = LatencyStatsAccounting(
    maxSamples: maxLatencySamples,
  );
}

class DHTPerKeyStats {
  //////////////////////////////

  final String debugName;

  final _stats = DHTCallStats();

  final _perFuncStats = <String, DHTCallStats>{};

  DHTPerKeyStats(this.debugName);

  void record(String func, TimestampDuration dur, Exception? exc) {
    final keyFuncStats = _perFuncStats.putIfAbsent(func, DHTCallStats.new);

    _stats.record(dur, exc);
    keyFuncStats.record(dur, exc);
  }

  String debugString() {
    //
    final out = StringBuffer()
      ..write('Name: $debugName\n')
      ..write(_stats.debugString().indent(4))
      ..writeln('Per-Function:');
    for (final entry in _perFuncStats.entries) {
      final funcName = entry.key;
      final funcStats = entry.value.debugString().indent(4);
      out.write('$funcName:\n$funcStats'.indent(4));
    }

    return out.toString();
  }
}

/// Kinds of retries observed in the DHT layer. Bumped from the retry hooks
/// in `DHTRecordPool.instance.retry` and `operateWriteEventual`. Cumulative since the
/// containing `DHTRecordPool` was created; consumers (benchmarks, debug UIs)
/// take a snapshot before/after an operation and diff to get per-op counts.
enum DHTRetryKind {
  outdated,
  tryAgain,
  notAvailable,
  keyNotFound,
  /// Transient network/connection error (Timeout, NoConnection, or a
  /// Generic with a "failed to connect" message). Retried by
  /// `DHTRecordPool.retry`.
  transient,
}

/// Cumulative retry counters keyed by [DHTRetryKind]. Returned by
/// [DHTStats.retrySnapshot]; subtract two snapshots to get per-op deltas.
class DHTRetrySnapshot {
  final Map<DHTRetryKind, int> counts;

  const DHTRetrySnapshot(this.counts);

  int operator [](DHTRetryKind kind) => counts[kind] ?? 0;

  /// Per-kind delta: `this - other`. Used to compute per-op retry totals.
  DHTRetrySnapshot diff(DHTRetrySnapshot other) =>
      DHTRetrySnapshot({
        for (final k in DHTRetryKind.values)
          k: (counts[k] ?? 0) - (other.counts[k] ?? 0),
      });
}

class DHTStats {
  //////////////////////////////

  final _statsPerKey = <RecordKey, DHTPerKeyStats>{};

  final _statsPerFunc = <String, DHTCallStats>{};

  final _retryCounts = <DHTRetryKind, int>{
    for (final k in DHTRetryKind.values) k: 0,
  };

  DHTStats();

  Future<T> measure<T>(
    RecordKey key,
    String debugName,
    String func,
    Future<T> Function() closure,
  ) async {
    //
    final start = Veilid.instance.now();
    final keyStats = _statsPerKey.putIfAbsent(
      key,
      () => DHTPerKeyStats(debugName),
    );
    final funcStats = _statsPerFunc.putIfAbsent(func, DHTCallStats.new);

    VeilidAPIException? exc;

    try {
      final res = await closure();

      return res;
    } on VeilidAPIException catch (e) {
      exc = e;
      rethrow;
    } finally {
      final end = Veilid.instance.now();
      final dur = end.diff(start);

      keyStats.record(func, dur, exc);
      funcStats.record(dur, exc);
    }
  }

  /// Bump the cumulative retry counter for [kind] and log via the pool's
  /// logger. Single hook for all retry sites so the diagnostic message is
  /// consistent across `DHTRecordPool.instance.retry` and `operateWriteEventual`.
  void recordRetry(DHTRetryKind kind, {String? context}) {
    final next = (_retryCounts[kind] ?? 0) + 1;
    _retryCounts[kind] = next;
    DHTRecordPool.instance.log(
      'DHT retry: ${kind.name} #$next${context == null ? '' : ' ($context)'}',
    );
  }

  /// Snapshot the cumulative retry counters. Diff two snapshots to get
  /// per-op deltas without mutating shared state.
  DHTRetrySnapshot retrySnapshot() => DHTRetrySnapshot({..._retryCounts});

  String debugString() {
    //
    final out = StringBuffer()..writeln('Per-Function:');
    for (final entry in _statsPerFunc.entries) {
      final funcName = entry.key;
      final funcStats = entry.value.debugString().indent(4);
      out.write('$funcName:\n$funcStats\n'.indent(4));
    }
    out.writeln('Per-Key:');
    for (final entry in _statsPerKey.entries) {
      final keyName = entry.key;
      final keyStats = entry.value.debugString().indent(4);
      out.write('$keyName:\n$keyStats\n'.indent(4));
    }
    out.writeln('Retries:');
    for (final entry in _retryCounts.entries) {
      out.write('${entry.key.name}: ${entry.value}\n'.indent(4));
    }

    return out.toString();
  }
}

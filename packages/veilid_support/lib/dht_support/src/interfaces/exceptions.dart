import 'dart:async';

import 'package:veilid/veilid.dart';

import '../../../src/veilid_log.dart';

/// Base class for every exception thrown out of veilid_support/dht_support.
///
/// veilid_support is written on top of VeilidAPI but must NEVER let a
/// VeilidAPI-level (or other unexpected Dart) exception escape its public
/// surface — callers should only ever have to handle [DHTException] subtypes.
/// Wrap public methods with [DHTException.wrap] to enforce this: any
/// VeilidAPIException or stray Exception that isn't already handled is logged
/// and converted into [DHTExceptionVeilidUncaught] / [DHTExceptionSystemUncaught]
/// so the leak is loud and discoverable rather than silently propagated.
abstract class DHTException implements Exception {
  const DHTException();

  /// Run [closure], guaranteeing no VeilidAPI-level exception escapes
  /// veilid_support. A [DHTException] passes through. Known VeilidAPIExceptions
  /// are translated to their meaning: invalid/missing argument → [ArgumentError]
  /// (caller misuse), transaction-not-found → [DHTExceptionOutdated], and
  /// key-not-found → [DHTExceptionNoRecord] (both mirror [DHTRecordPool.retry]).
  /// Anything left over becomes [DHTExceptionVeilidUncaught] (a stray
  /// VeilidAPIException) or [DHTExceptionSystemUncaught] (any other Exception).
  /// The two *Uncaught wrappers mark a spot we failed to handle and must NEVER
  /// be caught — they exist to surface our own bugs.
  static Future<T> wrap<T>(Future<T> Function() closure) async {
    try {
      return await closure();
    } on DHTException {
      rethrow;
    } on VeilidAPIExceptionInvalidArgument catch (e, st) {
      // Invalid argument == caller/library misuse (e.g. operating on a record
      // that isn't open). Surface as a Dart programming error carrying the
      // structured fields, not a recoverable DHT condition.
      veilidLoggy.error('invalid argument in veilid_support: $e\n$st');
      throw ArgumentError.value(e.value, e.argument, e.context);
    } on VeilidAPIExceptionMissingArgument catch (e, st) {
      // Missing required argument == caller/library misuse. Surface as a Dart
      // programming error.
      veilidLoggy.error('missing argument in veilid_support: $e\n$st');
      throw ArgumentError.notNull(e.argument);
    } on VeilidAPIExceptionTransactionNotFound catch (e) {
      // Transaction reached a terminal/failed stage (lost consensus, wrong
      // stage). Redo the whole operation. Mirrors DHTRecordPool.retry.
      throw DHTExceptionOutdated(cause: e.toDisplayError());
    } on VeilidAPIExceptionKeyNotFound catch (e) {
      // The record/key is gone. Mirrors DHTRecordPool.retry.
      throw DHTExceptionNoRecord(cause: e.toString());
    } on VeilidAPIExceptionTryAgain catch (e) {
      // Transient unavailability that outlived the VeilidAPI-level retry — the
      // DHT op gave up. Surface as the DHT-level transient.
      throw DHTExceptionNotAvailable(cause: e.toString());
    } on VeilidAPIExceptionTimeout catch (e) {
      throw DHTExceptionNotAvailable(cause: e.toString());
    } on VeilidAPIExceptionNoConnection catch (e) {
      throw DHTExceptionNotAvailable(cause: e.message);
    } on VeilidAPIException catch (e, st) {
      veilidLoggy.error('uncaught VeilidAPIException in veilid_support: $e\n$st');
      throw DHTExceptionVeilidUncaught(e);
    } on TimeoutException catch (e) {
      // A retry budget (RetryStrategy) exhausted while still transient. This is
      // a DHT-level transient, not an uncaught bug — surface it as such.
      veilidLoggy.debug('DHT operation gave up: offline / not ready: $e');
      throw DHTExceptionNotAvailable(cause: 'timed out: ${e.message}');
    } on Exception catch (e, st) {
      veilidLoggy.error('uncaught Exception in veilid_support: $e\n$st');
      throw DHTExceptionSystemUncaught(e);
    }
  }
}

/// A VeilidAPIException leaked out of a veilid_support operation that should
/// have handled it. This is always our bug — nothing should ever catch it.
class DHTExceptionVeilidUncaught extends DHTException {
  final VeilidAPIException inner;

  DHTExceptionVeilidUncaught(this.inner);

  @override
  String toString() => 'DHTExceptionVeilidUncaught: $inner';
}

/// A non-DHTException Dart exception leaked out of a veilid_support operation
/// that should have handled it. This is always our bug — nothing should ever
/// catch it.
class DHTExceptionSystemUncaught extends DHTException {
  final Exception inner;

  DHTExceptionSystemUncaught(this.inner);

  @override
  String toString() => 'DHTExceptionSystemUncaught: $inner';
}

class DHTExceptionOutdated extends DHTException {
  final String cause;

  const DHTExceptionOutdated({
    this.cause = 'operation failed due to newer dht value',
  });

  @override
  String toString() => 'DHTExceptionOutdated: $cause';
}

class DHTExceptionLimit extends DHTException {
  final String cause;
  final int requested;
  final int limit;

  const DHTExceptionLimit({
    required this.requested,
    required this.limit,
    this.cause = 'requested length exceeds limit',
  });

  @override
  String toString() => 'DHTExceptionLimit: $cause '
      '(requested=$requested, limit=$limit)';
}

class DHTExceptionInvalidData extends DHTException {
  final String cause;

  const DHTExceptionInvalidData({this.cause = 'data was invalid'});

  @override
  String toString() => 'DHTExceptionInvalidData: $cause';
}

class DHTExceptionCancelled extends DHTException {
  final String cause;

  const DHTExceptionCancelled({this.cause = 'operation was cancelled'});

  @override
  String toString() => 'DHTExceptionCancelled: $cause';
}

class DHTExceptionNotAvailable extends DHTException {
  final String cause;

  const DHTExceptionNotAvailable({
    this.cause = 'request could not be completed at this time',
  });

  @override
  String toString() => 'DHTExceptionNotAvailable: $cause';
}

class DHTExceptionNoRecord extends DHTException {
  final String cause;

  const DHTExceptionNoRecord({this.cause = 'record could not be found'});

  @override
  String toString() => 'DHTExceptionNoRecord: $cause';
}

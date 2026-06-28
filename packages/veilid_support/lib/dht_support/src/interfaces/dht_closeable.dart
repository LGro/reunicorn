import 'dart:async';

import 'package:meta/meta.dart';

import '../../../src/debug_name.dart';

abstract interface class DHTCloseable {
  /// Marks the object as closed and ready to be deleted or destroyed
  /// Returns true if the object was closed fully
  /// Returns false if the close was acknowledged but not processed yet
  @mustCallSuper
  Future<bool> close();

  /// True if the object is still open or close is pending
  /// False if it has been closed fully
  bool get isOpen;
}

abstract interface class DHTRefCounted implements DHTCloseable {
  /// Add a reference count to a reference-counted object
  void ref();
}

mixin DefaultDHTRefCounted implements DHTRefCounted, DebugName {
  // Start in the 'opened' state with one reference
  int _openCount = 1;

  @override
  void ref() {
    _openCount++;
  }

  @override
  @mustCallSuper
  Future<bool> close() async {
    if (_openCount == 0) {
      throw StateError('$debugName is already closed');
    }
    _openCount--;
    if (_openCount != 0) {
      return false;
    }

    return true;
  }

  @override
  bool get isOpen => _openCount > 0;
}

abstract interface class DHTScoped<T> implements DHTCloseable, DebugName {
  FutureOr<T> scoped();
}

abstract interface class DHTDeleteScoped<T>
    implements DHTDeleteable, DHTScoped<T> {}

abstract interface class DHTDeleteable {
  /// Returns true if the deletion was processed immediately
  /// Returns false if the deletion was marked for later
  Future<bool> delete();

  /// True if this object has been deleted or is marked for deletion
  bool get isDeleted;
}

mixin DefaultDHTDeleteable implements DHTDeleteable, DHTRefCounted, DebugName {
  @mustCallSuper
  @mustBeOverridden
  @override
  Future<bool> delete() async {
    if (!isOpen) {
      throw StateError('$debugName must be deleted before close');
    }
    if (isDeleted) {
      // Allow multiple delete calls before close
      return true;
    }
    _isDeleted = true;
    return true;
  }

  @override
  bool get isDeleted => _isDeleted;

  bool _isDeleted = false;
}

extension DHTCloseableExt<D> on DHTScoped<D> {
  /// Runs a closure that guarantees the DHTCloseable
  /// will be closed upon exit, even if an uncaught exception is thrown
  Future<T> scope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('$debugName not open in scope');
    }
    try {
      return await scopeFunction(await scoped());
    } finally {
      await close();
    }
  }
}

extension DHTDeletableExt<D> on DHTDeleteScoped<D> {
  /// Runs a closure that guarantees the DHTDeleteable
  /// will be closed upon exit, and deleted if an an
  /// uncaught exception is thrown
  Future<T> deleteScope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('"$debugName" not open in deleteScope');
    }

    try {
      return await scopeFunction(await scoped());
    } on Exception {
      await delete();
      rethrow;
    } finally {
      await close();
    }
  }

  /// Scopes a closure that conditionally deletes the DHTCloseable on exit
  Future<T> maybeDeleteScope<T>(
    bool delete,
    Future<T> Function(D) scopeFunction,
  ) {
    if (delete) {
      return deleteScope(scopeFunction);
    }
    return scope(scopeFunction);
  }
}

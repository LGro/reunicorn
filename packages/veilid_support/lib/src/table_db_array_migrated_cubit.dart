import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

@immutable
class TableDBArrayMigratedStateData<T> extends Equatable {
  // The view of the elements in the dhtlog
  // Span is from [tail-length, tail)
  final IList<T> windowElements;

  // The length of the entire array
  final int length;

  // One past the end of the last element (modulo length, can be zero)
  final int windowTail;

  // The total number of elements to try to keep in 'elements'
  final int windowCount;

  // If we should have the tail following the array
  final bool follow;

  const TableDBArrayMigratedStateData({
    required this.windowElements,
    required this.length,
    required this.windowTail,
    required this.windowCount,
    required this.follow,
  });

  @override
  List<Object?> get props => [windowElements, windowTail, windowCount, follow];
}

typedef TableDBArrayMigratedState<T> =
    AsyncValue<TableDBArrayMigratedStateData<T>>;
typedef TableDBArrayMigratedBusyState<T> =
    BlocBusyState<TableDBArrayMigratedState<T>>;

class TableDBArrayMigratedCubit<T>
    extends Cubit<TableDBArrayMigratedBusyState<T>>
    with BlocBusyWrapper<TableDBArrayMigratedState<T>> {
  final WaitSet<void, void> _initWait = WaitSet();

  late final TableDBArrayMigrated<T> _array;

  StreamSubscription<void>? _subscription;

  var _wantsCloseArray = false;

  final _sspUpdate = SingleStatelessProcessor();

  // Accumulated deltas since last update
  var _headDelta = 0;

  var _tailDelta = 0;

  // Cubit window into the TableDBArray
  var _tail = 0;

  var _count = DHTShortArray.maxElements;

  var _follow = true;

  TableDBArrayMigratedCubit({
    required Future<TableDBArrayMigrated<T>> Function() open,
  }) : super(const BlocBusyState(AsyncValue.loading())) {
    _initWait.add((_) async {
      // Open table db array
      _array = await open();
      _wantsCloseArray = true;

      // Make initial state update
      await _refreshNoWait();
      _subscription = await _array.listen(_update);
    });
  }

  // Set the tail position of the array for pagination.
  // If tail is 0, the end of the array is used.
  // If tail is negative, the position is subtracted from the current array
  // length.
  // If tail is positive, the position is absolute from the head of the array
  // If follow is enabled, the tail offset will update when the array changes
  Future<void> setWindow({
    int? tail,
    int? count,
    bool? follow,
    bool forceRefresh = false,
  }) async {
    await _initWait();
    if (tail != null) {
      _tail = tail;
    }
    if (count != null) {
      _count = count;
    }
    if (follow != null) {
      _follow = follow;
    }
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    await _initWait();
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> _refreshNoWait({bool forceRefresh = false}) =>
      busy((emit) => _refreshInner(emit, forceRefresh: forceRefresh));

  Future<void> _refreshInner(
    void Function(AsyncValue<TableDBArrayMigratedStateData<T>>) emit, {
    bool forceRefresh = false,
  }) async {
    final avElements = await _loadElements(_tail, _count);
    final err = avElements.asError;
    if (err != null) {
      addError(err.error, err.stackTrace);
      emit(AsyncValue.error(err.error, err.stackTrace));
      return;
    }
    final loading = avElements.asLoading;
    if (loading != null) {
      emit(const AsyncValue.loading());
      return;
    }
    final elements = avElements.asData!.value;
    emit(
      AsyncValue.data(
        TableDBArrayMigratedStateData(
          windowElements: elements,
          length: _array.length,
          windowTail: _tail,
          windowCount: _count,
          follow: _follow,
        ),
      ),
    );
  }

  Future<AsyncValue<IList<T>>> _loadElements(int tail, int count) async {
    try {
      final length = _array.length;
      if (length == 0) {
        return AsyncValue.data(IList<T>.empty());
      }
      final end = ((tail - 1) % length) + 1;
      final start = (count < end) ? end - count : 0;
      final allItems = (await _array.getRange(start, end)).toIList();
      return AsyncValue.data(allItems);
    } on Exception catch (e, st) {
      addError(e, st);
      return AsyncValue.error(e, st);
    }
  }

  void _update(TableDBArrayUpdate upd) {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one. Only called after init future has run
    // so we dont have to wait for that here.

    // Accumulate head and tail deltas
    _headDelta += upd.headDelta;
    _tailDelta += upd.tailDelta;

    _sspUpdate.busyUpdate<T, TableDBArrayMigratedState<T>>(busy, (emit) async {
      // apply follow
      if (_follow) {
        if (_tail <= 0) {
          // Negative tail is already following tail changes
        } else {
          // Positive tail is measured from the head, so apply deltas
          _tail = (_tail + _tailDelta - _headDelta) % upd.length;
        }
      } else {
        if (_tail <= 0) {
          // Negative tail is following tail changes so apply deltas
          var posTail = _tail + upd.length;
          posTail = (posTail + _tailDelta - _headDelta) % upd.length;
          _tail = posTail - upd.length;
        } else {
          // Positive tail is measured from head so not following tail
        }
      }
      _headDelta = 0;
      _tailDelta = 0;

      await _refreshInner(emit);
    });
  }

  @override
  Future<void> close() async {
    await _initWait();
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseArray) {
      await _array.close();
    }
    await super.close();
  }

  Future<R?> operate<R>(
    Future<R?> Function(TableDBArrayMigrated<T>) closure,
  ) async {
    await _initWait();
    return closure(_array);
  }
}

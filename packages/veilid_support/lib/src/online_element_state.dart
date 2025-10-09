import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class OnlineElementState<T> extends Equatable {
  final T value;
  final bool isOffline;

  const OnlineElementState({required this.value, required this.isOffline});

  @override
  List<Object?> get props => [value, isOffline];
}

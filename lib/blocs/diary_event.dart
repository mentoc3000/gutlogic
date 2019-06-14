import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DiaryEvent extends Equatable {
  DiaryEvent([List props = const []]) : super(props);
}


class Fetch extends DiaryEvent {
  @override
  String toString() => 'Fetch';
}


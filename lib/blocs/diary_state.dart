import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import '../models/diary_entry.dart';

@immutable
abstract class DiaryState extends Equatable {
  DiaryState([List props = const []]) : super(props);
}

class InitialDiaryState extends DiaryState {}

class DiaryInitial extends DiaryState {
  @override
  String toString() => 'DiarysUninitialized';
}

class DiaryError extends DiaryState {
  @override
  String toString() => 'DiaryError';
}

class DiaryLoaded extends DiaryState {

  @override
  String toString() => 'DiaryLoaded';
}

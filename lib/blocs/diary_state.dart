import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import '../models/diary_entry.dart';

@immutable
abstract class DiaryState extends Equatable {
  DiaryState([List props = const []]) : super(props);
}

class InitialDiaryState extends DiaryState {}

class DiaryUninitialized extends DiaryState {
  @override
  String toString() => 'DiarysUninitialized';
}

class DiaryError extends DiaryState {
  @override
  String toString() => 'DiaryError';
}

class DiaryLoaded extends DiaryState {
  final BuiltList<DiaryEntry> diaryEntries;

  DiaryLoaded({this.diaryEntries}) : super([diaryEntries]);

  // DiaryLoaded copyWith({
  //   BuiltList<DiaryEntry> diaryEntries,
  // }) {
  //   return DiaryLoaded(
  //     diaryEntries: diaryEntries ?? this.diaryEntries,
  //   );
  // }

  @override
  String toString() => 'DiaryLoaded { diaryEntries: ${diaryEntries.length} }';
}

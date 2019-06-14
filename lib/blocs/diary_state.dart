import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/diary_entry.dart';

@immutable
abstract class DiaryState extends Equatable {
  DiaryState([List props = const []]) : super(props);
}

class DiaryLoading extends DiaryState {
  @override
  String toString() => 'DiaryLoading';
}

class DiaryLoaded extends DiaryState {
  final List<DiaryEntry> diaryEntries;

  DiaryLoaded([this.diaryEntries = const []]) : super([diaryEntries]);

  @override
  String toString() => 'DiaryEntriesLoaded { count: ${diaryEntries.length} }';
}

class DiaryNotLoaded extends DiaryState {
  @override
  String toString() => 'DiaryNotLoaded';
}
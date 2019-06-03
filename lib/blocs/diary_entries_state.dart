import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/diary_entry.dart';

@immutable
abstract class DiaryEntriesState extends Equatable {
  DiaryEntriesState([List props = const []]) : super(props);
}

class DiaryEntriesLoading extends DiaryEntriesState {
  @override
  String toString() => 'DiaryEntriesLoading';
}

class DiaryEntriesLoaded extends DiaryEntriesState {
  final List<DiaryEntry> diaryEntries;

  DiaryEntriesLoaded([this.diaryEntries = const []]) : super([diaryEntries]);

  @override
  String toString() => 'DiaryEntriesLoaded { count: ${diaryEntries.length} }';
}

class DiaryEntriesNotLoaded extends DiaryEntriesState {
  @override
  String toString() => 'DiaryEntriesNotLoaded';
}
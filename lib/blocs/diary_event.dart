import 'package:equatable/equatable.dart';

abstract class DiaryEvent extends Equatable {
  @override
  List<Object> get props => [];
}


class LoadDiary extends DiaryEvent {
  @override
  String toString() => 'LoadDiary';
}


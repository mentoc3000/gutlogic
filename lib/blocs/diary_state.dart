import 'package:equatable/equatable.dart';

abstract class DiaryState extends Equatable {
  @override
  List<Object> get props => [];
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

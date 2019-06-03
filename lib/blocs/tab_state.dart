import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TabState extends Equatable {
  TabState([List props = const []]) : super(props);
}

class DiaryTabState extends TabState {
  @override
  String toString() => 'DiaryTabState';
}

class SearchTabState extends TabState {
  @override
  String toString() => 'SearchTabState';
}

class ChatTabState extends TabState {
  @override
  String toString() => 'ChatTabState';
}

class AccountTabState extends TabState {
  @override
  String toString() => 'AccountTabState';
}

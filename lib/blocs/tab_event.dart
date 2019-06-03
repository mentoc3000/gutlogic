import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TabEvent extends Equatable {
  TabEvent([List props = const []]) : super(props);
}

class DiaryTabPressed extends TabEvent {
  @override
  String toString() => 'DiaryTabPressed';
}

class SearchTabPressed extends TabEvent {
  @override
  String toString() => 'SearchTabPressed';
}

class ChatTabPressed extends TabEvent {
  @override
  String toString() => 'ChatTabPressed';
}

class AccountTabPressed extends TabEvent {
  @override
  String toString() => 'AccountTabPressed';
}

import 'package:equatable/equatable.dart';
import 'tab_state.dart';

abstract class TabEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateTab extends TabEvent {
  final AppTab tab;

  UpdateTab(this.tab);

  @override
  List<Object> get props => [tab];

  @override
  String toString() => 'UpdateTab { tab: $tab }';
}

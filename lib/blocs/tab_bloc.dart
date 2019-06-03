import 'dart:async';
import 'package:bloc/bloc.dart';
import './tab_event.dart';
import './tab_state.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  @override
  TabState get initialState => InitialTabState();

  @override
  Stream<TabState> mapEventToState(
    TabEvent event,
  ) async* {
    // TODO: Add Logic
  }
}

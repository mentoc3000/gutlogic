import 'dart:async';
import 'package:bloc/bloc.dart';
import './tab_event.dart';
import './tab_state.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  @override
  TabState get initialState => DiaryTabState();

  @override
  Stream<TabState> mapEventToState(
    TabEvent event,
  ) async* {
    if (event is DiaryTabPressed) {
      yield DiaryTabState();
    }

    if (event is SearchTabPressed) {
      yield SearchTabState();
    }

    if (event is ChatTabPressed) {
      yield ChatTabState();
    }

    if (event is AccountTabPressed) {
      yield AccountTabState();
    }
  }
}

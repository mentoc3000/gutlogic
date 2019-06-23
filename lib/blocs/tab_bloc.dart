import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';
import './tab_event.dart';
import './tab_state.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  @override
  AppTab get initialState => AppTab.diary;

  @override
  Stream<AppTab> mapEventToState(TabEvent event) async* {
    if (event is UpdateTab) {
      yield event.tab;
    }
  }
}

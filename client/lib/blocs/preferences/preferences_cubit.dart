import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/preferences/preferences.dart';
import '../../resources/preferences_service.dart';
import '../bloc_helpers.dart';
import 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> with StreamSubscriber<_PreferencesData, PreferencesState> {
  final PreferencesService repository;
  final IrritantService irritantService;

  PreferencesCubit({required this.repository, required this.irritantService}) : super(const PreferencesLoading()) {
    final irritants = irritantService.names().asStream();
    final prefences = repository.stream;
    final state = CombineLatestStream.combine2(
      irritants,
      prefences,
      (irritantsValue, preferencesValue) => _PreferencesData(preferences: preferencesValue, irritants: irritantsValue),
    );
    streamSubscription = state.listen((data) {
      emit(PreferencesLoaded(preferences: data.preferences, irritants: data.irritants.toBuiltList()));
    });
  }

  static BlocProvider<PreferencesCubit> provider({required Widget child}) {
    return BlocProvider(
      create: (c) {
        return PreferencesCubit(
          repository: c.read<PreferencesService>(),
          irritantService: c.read<IrritantService>(),
        );
      },
      child: child,
    );
  }

  Future<void> update(Preferences preferences) async {
    try {
      await repository.update(preferences);
    } catch (ex) {
      emit(PreferencesFailure(message: 'Failed to update irritant filter'));
    }
  }

  Future<void> updateIrritantFilter(String irritant, bool include) async {
    try {
      await repository.updateIrritantFilter(irritant, include);
    } catch (ex) {
      emit(PreferencesFailure(message: 'Failed to update irritant filter'));
    }
  }
}

class _PreferencesData {
  final Preferences preferences;
  final BuiltSet<String> irritants;

  _PreferencesData({required this.preferences, required this.irritants});
}

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food_group_entry.dart';
import '../../resources/food_group_repository.dart';
import '../../resources/irritant_service.dart';
import 'food_group_state.dart';

class FoodGroupCubit extends Cubit<FoodGroupState> {
  final String group;
  final IrritantService irritantService;
  StreamSubscription<BuiltMap<FoodGroupEntry, Intensity>>? maxIntensitySubscription;

  FoodGroupCubit({
    required FoodGroupsRepository repository,
    required this.group,
    required this.irritantService,
  }) : super(const FoodGroupLoading()) {
    repository.foods(group: group).then(_onData, onError: _onError);
  }

  factory FoodGroupCubit.fromContext(BuildContext context, {required String group}) {
    return FoodGroupCubit(
      repository: context.read<FoodGroupsRepository>(),
      group: group,
      irritantService: context.read<IrritantService>(),
    );
  }

  void _onData(BuiltSet<FoodGroupEntry> entries) async {
    final entriesList = entries.toList();

    // Get the maximum intensity for each food
    await maxIntensitySubscription?.cancel();
    maxIntensitySubscription = CombineLatestStream(
      entriesList.map((e) => irritantService.maxIntensity(e.doses, usePreferences: true)),
      (maxIntensities) => BuiltMap<FoodGroupEntry, Intensity>(Map.fromIterables(entriesList, maxIntensities)),
    ).listen(
      (maxIntensitiesMap) {
        if (!isClosed) {
          emit(FoodGroupLoaded(foods: entries, maxIntensities: maxIntensitiesMap));
        }
      },
      onError: _onError,
    );
  }

  void _onError(Object error, StackTrace trace) {
    if (!isClosed) {
      emit(FoodGroupError.fromError(error: error, trace: trace));
    }
  }

  @override
  Future<void> close() {
    maxIntensitySubscription?.cancel();
    return super.close();
  }
}

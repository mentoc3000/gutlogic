import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food_group_entry.dart';
import '../../resources/food_group_repository.dart';
import '../../resources/irritant_service.dart';
import '../../util/fuzzy.dart';
import 'food_group_search_state.dart';

class FoodGroupSearchCubit extends Cubit<FoodGroupSearchState> {
  final FoodGroupsRepository foodGroupsRepository;
  final IrritantService irritantService;
  StreamSubscription<BuiltMap<FoodGroupEntry, Intensity>>? maxIntensitySubscription;

  FoodGroupSearchCubit({
    required this.foodGroupsRepository,
    required this.irritantService,
  }) : super(FoodGroupSearchLoaded.empty());

  factory FoodGroupSearchCubit.fromContext(BuildContext context) {
    return FoodGroupSearchCubit(
      foodGroupsRepository: context.read<FoodGroupsRepository>(),
      irritantService: context.read<IrritantService>(),
    );
  }

  void query(String query) async {
    try {
      if (query.isEmpty) emit(FoodGroupSearchLoaded.empty());

      // Load cache
      final entries = await foodGroupsRepository.foods();
      final entriesList = entries.toList();

      await maxIntensitySubscription?.cancel();
      maxIntensitySubscription = CombineLatestStream(
        entriesList.map((e) => irritantService.maxIntensity(e.doses, usePreferences: true)),
        (maxIntensities) => BuiltMap<FoodGroupEntry, Intensity>(Map.fromIterables(entriesList, maxIntensities)),
      ).listen(
        (maxIntensitiesMap) {
          if (!isClosed) {
            if (query.isNotEmpty) {
              final entries = stringMatchSort(
                list: maxIntensitiesMap.keys.toList(),
                match: query,
                keyOf: (FoodGroupEntry e) => e.foodRef.name,
              );
              final maxIntensities =
                  BuiltMap<FoodGroupEntry, Intensity>({for (var e in entries) e: maxIntensitiesMap[e]});
              emit(FoodGroupSearchLoaded(foods: BuiltList(entries), maxIntensities: maxIntensities));
            }
          }
        },
        onError: _onError,
      );
    } catch (error, trace) {
      _onError(error, trace);
    }
  }

  void _onError(Object error, StackTrace trace) {
    if (!isClosed) {
      emit(FoodGroupSearchError.fromError(error: error, trace: trace));
    }
  }
}

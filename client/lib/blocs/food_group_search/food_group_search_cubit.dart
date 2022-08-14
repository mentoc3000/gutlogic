import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_group_entry.dart';
import '../../resources/food_group_repository.dart';
import '../../resources/irritant_service.dart';
import '../../util/fuzzy.dart';
import 'food_group_search_state.dart';

class FoodGroupSearchCubit extends Cubit<FoodGroupSearchState> {
  final FoodGroupsRepository foodGroupsRepository;
  final IrritantService irritantService;
  BuiltMap<FoodGroupEntry, int?>? _maxIntensitiesMapCache;

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
      if (_maxIntensitiesMapCache == null) {
        final entries = await foodGroupsRepository.foods();
        final entriesList = entries.toList();
        final maxIntensitiesList = await Future.wait(entries.map((e) => irritantService.maxIntensity(e.doses)));
        _maxIntensitiesMapCache =
            BuiltMap<FoodGroupEntry, int>.from(Map.fromIterables(entriesList, maxIntensitiesList));
      }

      if (query.isNotEmpty) {
        final entries = stringMatchSort(
          list: _maxIntensitiesMapCache!.keys.toList(),
          match: query,
          keyOf: (FoodGroupEntry e) => e.foodRef.name,
        );
        final maxIntensities = BuiltMap<FoodGroupEntry, int?>({for (var e in entries) e: _maxIntensitiesMapCache![e]});
        emit(FoodGroupSearchLoaded(foods: BuiltList(entries), maxIntensities: maxIntensities));
      }
    } catch (error, trace) {
      emit(FoodGroupSearchError.fromError(error: error, trace: trace));
    }
  }
}

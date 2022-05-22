import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_group_entry.dart';
import '../../resources/food_group_repository.dart';
import '../../resources/irritant_service.dart';
import '../bloc_helpers.dart';
import 'food_group_state.dart';

class FoodGroupCubit extends Cubit<FoodGroupState> with StreamSubscriber {
  final String group;
  final IrritantService irritantService;

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
    final irritantsList = await Future.wait(entriesList.map((p0) => irritantService.ofRef(p0.foodRef)));
    final maxIntensitiesList = await Future.wait(irritantsList.map((e) => irritantService.maxIntensity(e)));
    final maxIntensitiesMap = BuiltMap<FoodGroupEntry, int>.from(Map.fromIterables(entriesList, maxIntensitiesList));
    emit(FoodGroupLoaded(foods: entries, maxIntensities: maxIntensitiesMap));
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodGroupError.fromError(error: error, trace: trace));
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_group.dart';
import '../../resources/food_group_repository.dart';
import '../bloc_helpers.dart';
import 'food_groups_state.dart';

class FoodGroupsCubit extends Cubit<FoodGroupsState> with StreamSubscriber {
  FoodGroupsCubit({required FoodGroupsRepository repository}) : super(const FoodGroupsLoading()) {
    repository.all().then(_onData, onError: _onError);
  }

  factory FoodGroupsCubit.fromContext(BuildContext context) {
    return FoodGroupsCubit(repository: context.read<FoodGroupsRepository>());
  }

  void _onData(Iterable<FoodGroup>? foodGroups) {
    if (foodGroups != null) {
      emit(FoodGroupsLoaded(foodGroups: foodGroups));
    } else {
      emit(FoodGroupsError(message: 'Food groups not found'));
    }
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodGroupsError.fromError(error: error, trace: trace));
  }
}

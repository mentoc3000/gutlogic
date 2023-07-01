import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/food_group_repository.dart';
import 'food_groups_state.dart';

class FoodGroupsCubit extends Cubit<FoodGroupsState> {
  FoodGroupsCubit({required FoodGroupsRepository repository}) : super(const FoodGroupsLoading()) {
    repository.groups().then(_onData, onError: _onError);
  }

  factory FoodGroupsCubit.fromContext(BuildContext context) {
    return FoodGroupsCubit(repository: context.read<FoodGroupsRepository>());
  }

  void _onData(BuiltSet<String>? groups) {
    if (!isClosed) {
      if (groups != null) {
        emit(FoodGroupsLoaded(groups: groups));
      } else {
        emit(FoodGroupsError(message: 'Food groups not found'));
      }
    }
  }

  void _onError(Object error, StackTrace trace) {
    if (!isClosed) {
      emit(FoodGroupsError.fromError(error: error, trace: trace));
    }
  }
}

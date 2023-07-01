import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_reference/food_reference.dart';
import 'foods_suggestion_state.dart';

abstract class FoodSuggestionCubit extends Cubit<FoodsSuggestionState> {
  final Future<BuiltList<FoodReference>> Function() foodsGetter;

  FoodSuggestionCubit({required this.foodsGetter}) : super(const FoodsSuggestionLoading()) {
    update();
  }

  void update() {
    foodsGetter().then(onRepoValue, onError: onRepoError);
  }

  void onRepoValue(BuiltList<FoodReference> recentFoods) {
    if (!isClosed) {
      emit(FoodsSuggestionLoaded(recentFoods));
    }
  }

  void onRepoError(Object error, StackTrace trace) {
    if (!isClosed) {
      emit(FoodsSuggestionError.fromError(error: error, trace: trace));
    }
  }
}

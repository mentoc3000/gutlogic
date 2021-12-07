import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../resources/food/food_service.dart';
import '../bloc_helpers.dart';
import 'food_state.dart';

class FoodCubit extends Cubit<FoodState> with StreamSubscriber {
  final FoodService foodService;

  FoodCubit({required this.foodService}) : super(FoodLoading());

  factory FoodCubit.fromContext(BuildContext context) => FoodCubit(foodService: context.read<FoodService>());

  void get(FoodReference foodReference) {
    streamSubscription?.cancel();
    streamSubscription = foodService.streamFood(foodReference).listen(_onData, onError: _onError);
  }

  void _onData(Food? food) {
    if (food != null) {
      emit(FoodLoaded(food: food));
    } else {
      emit(FoodError(message: 'Food not found'));
    }
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodError.fromError(error: error, trace: trace));
  }
}

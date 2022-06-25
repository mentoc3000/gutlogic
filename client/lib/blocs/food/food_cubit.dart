import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../resources/food/food_service.dart';
import '../../resources/irritant_service.dart';
import '../bloc_helpers.dart';
import 'food_state.dart';

class FoodCubit extends Cubit<FoodState> with StreamSubscriber<Food?, FoodState> {
  final IrritantService irritantService;

  FoodCubit({
    required FoodService foodService,
    required this.irritantService,
    required FoodReference foodReference,
  }) : super(FoodLoading(foodReference: foodReference)) {
    streamSubscription = foodService.streamFood(foodReference).listen(_onData, onError: _onError);
  }

  factory FoodCubit.fromContext(BuildContext context, {required FoodReference foodReference}) {
    return FoodCubit(
      foodService: context.read<FoodService>(),
      irritantService: context.read<IrritantService>(),
      foodReference: foodReference,
    );
  }

  void _onData(Food? food) async {
    if (food != null) {
      final irritants = await irritantService.ofRef(food.toFoodReference());
      emit(FoodLoaded(food: food, irritants: irritants));
    } else {
      emit(FoodError(message: 'Food not found'));
    }
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodError.fromError(error: error, trace: trace));
  }
}

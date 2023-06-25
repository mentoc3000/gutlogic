import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/resources/preferences_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/preferences/preferences.dart';
import '../../resources/food/food_service.dart';
import '../../resources/irritant_service.dart';
import '../bloc_helpers.dart';
import 'food_state.dart';

class FoodCubit extends Cubit<FoodState> with StreamSubscriber<_Data, FoodState> {
  final IrritantService irritantService;

  FoodCubit({
    required FoodService foodService,
    required this.irritantService,
    required PreferencesService preferencesService,
    required FoodReference foodReference,
  }) : super(FoodLoading(foodReference: foodReference)) {
    final foodStream = foodService.streamFood(foodReference);
    final preferencesStream = preferencesService.stream;
    final dataStream = CombineLatestStream.combine2(foodStream, preferencesStream, _Data.combine);
    streamSubscription = dataStream.listen(_onData, onError: _onError);
  }

  factory FoodCubit.fromContext(BuildContext context, {required FoodReference foodReference}) {
    return FoodCubit(
      foodService: context.read<FoodService>(),
      irritantService: context.read<IrritantService>(),
      preferencesService: context.read<PreferencesService>(),
      foodReference: foodReference,
    );
  }

  void _onData(_Data data) async {
    if (data.food != null) {
      emit(FoodLoaded(food: data.food!, excludedIrritants: data.preferences.irritantsExcluded ?? BuiltSet()));
    } else {
      emit(FoodError(message: 'Food not found'));
    }
  }

  void _onError(Object error, StackTrace trace) {
    emit(FoodError.fromError(error: error, trace: trace));
  }
}

class _Data {
  final Food? food;
  final Preferences preferences;

  _Data({
    required this.food,
    required this.preferences,
  });

  factory _Data.combine(Food? food, Preferences preferences) => _Data(food: food, preferences: preferences);
}

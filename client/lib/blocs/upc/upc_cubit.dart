import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../resources/food/food_service.dart';
import 'upc_state.dart';

class UpcCubit extends Cubit<UpcState> {
  final FoodService foodService;

  UpcCubit({required this.foodService}) : super(const UpcScanning());

  factory UpcCubit.fromContext(BuildContext context) {
    return UpcCubit(foodService: context.read<FoodService>());
  }

  void reactivateScanner() {
    emit(const UpcScanning());
  }

  void findFood({required Iterable<String> upcs}) async {
    emit(UpcsFound(upcs: upcs));

    // TODO: is there a prettier way to do this using stream functions?
    // Get the food for all upcs
    final food = await Stream.fromFutures(upcs.map((upc) => foodService.streamUpc(upc).first))
        // Remove cases where no matching food could be found
        .where((food) => food != null)
        // If no matching foods are found, emit a null
        .defaultIfEmpty(null)
        .first;

    if (food == null) {
      emit(const FoodNotFound());
    } else {
      emit(FoodFound(food: food));
    }
  }
}

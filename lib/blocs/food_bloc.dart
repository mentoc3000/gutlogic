import '../resources/food_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/food.dart';
import '../resources/app_sync_service.dart';
import 'bloc_interfaces.dart';

class FoodBloc extends SearchableBloc{

  FoodBloc(AppSyncService appSyncService)
      : super(repository: FoodRepository(appSyncService));

  Stream<List<Food>> get all => controller.stream.cast();
}

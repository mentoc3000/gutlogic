import '../resources/food_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/food.dart';
import '../resources/app_sync_service.dart';
import 'searchable_bloc.dart';

class FoodBloc extends SearchableBloc<Food,FoodRepository> {
  FoodBloc(AppSyncService appSyncService)
      : super(FoodRepository(appSyncService));
}

import '../resources/food_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/food.dart';
import '../resources/app_sync_service.dart';

class FoodBloc {
  // final AppSyncService appSyncService;
  final FoodRepository foodRepository;

  FoodBloc(AppSyncService appSyncService)
      : this.foodRepository = FoodRepository(appSyncService);

  // Use broadcast stream because stream in search gets subscribed to multiple times
  final _foodsController = StreamController<List<Food>>.broadcast();

  Stream<List<Food>> get allFoods => _foodsController.stream;

  fetchAllFoods() async {
    List<Food> foods = await foodRepository.fetchAllFoods();
    _foodsController.sink.add(foods);
  }

  fetchQuery(String query) async {
    List<Food> foods = await foodRepository.fetchQuery(query);
    _foodsController.sink.add(foods);
  }

  dispose() {
    _foodsController.close();
  }
}

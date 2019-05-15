import '../resources/food_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/food.dart';
import '../resources/app_sync_service.dart';
import 'bloc_interfaces.dart';

class FoodBloc implements SearchableBloc{
  // final AppSyncService appSyncService;
  final FoodRepository foodRepository;

  FoodBloc(AppSyncService appSyncService)
      : this.foodRepository = FoodRepository(appSyncService);

  // Use broadcast stream because stream in search gets subscribed to multiple times
  final _foodsController = StreamController<List<Food>>.broadcast();

  Stream<List<Food>> get all => _foodsController.stream;

  fetchAll() async {
    List<Food> foods = await foodRepository.fetchAll();
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

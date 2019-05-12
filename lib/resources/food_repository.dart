import 'dart:async';
import 'dummy_data.dart';
import '../models/food.dart';
import 'app_sync_service.dart';

class FoodRepository {
  final AppSyncService appSyncService;

  FoodRepository(this.appSyncService);

  // Future<List<Food>> fetchAllFoods() => Future(() => Dummy.foodList);
  Future<List<Food>> fetchAllFoods() async {
    const operationName = 'listFoods';
    const operation = 'listFoods { items { name } }';
    final response = await appSyncService.query(operationName, operation);
    return AppSyncService.getItems(response, operationName)
        .map((x) => Food.fromJson(x)).toList();
  }

  Future<List<Food>> fetchQuery(String query) {
    return Future(() {
      if (query == '') {
        return fetchAllFoods();
      }
      return Dummy.foodList.where((f) => f.name.contains(query)).toList();
    });
  }
}

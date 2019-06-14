import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/food.dart';
import 'app_sync_service.dart';
import 'searchable_repository.dart';
import 'database_repository.dart';
import '../models/serializers.dart';

class FoodRepository extends DatabaseRepository {
  final AppSyncService appSyncService;

  FoodRepository(this.appSyncService) : super();

  // Future<List<Food>> fetchAllFoods() => Future(() => Dummy.foodList);
  @override
  Future<BuiltList<Food>> fetchAll() async {
    const operationName = 'listFoods';
    const operation = 'listFoods { items { name } }';
    final response = await appSyncService.query(operationName, operation);
    return AppSyncService.getItems(response, operationName)
        .map((x) => serializers.deserializeWith(Food.serializer, x));
  }

  @override
  Future<BuiltList<Food>> fetchQuery(String query) async {
    final allFoods = await fetchAll();
      if (query == '') {
        return allFoods;
      }
      return allFoods.where((f) => f.name.contains(query));
  }
}

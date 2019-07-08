import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/food.dart';
import 'app_sync_service.dart';
import 'searchable_repository.dart';
import '../models/serializers.dart';

class FoodRepository extends SearchableRepository<Food> {
  final AppSyncService appSyncService;

  FoodRepository(this.appSyncService) : super();

  @override
  Future<BuiltList<Food>> fetchAll() async {
    const operationName = 'listFoods';
    const operation = 'listFoods { items { name } }';
    final response = await appSyncService.query(operationName, operation);
    return BuiltList<Food>(AppSyncService.getItems(response, operationName)
        .map((x) => serializers.deserializeWith(Food.serializer, x)));
  }

  @override
  Future<BuiltList<Food>> fetchQuery(String query) async {
    const operationName = 'listFoods';
    String operation = 'listFoods(filter: {name: {contains: "$query"}}) { items { name } }';
    final response = await appSyncService.query(operationName, operation);
    return BuiltList<Food>(AppSyncService.getItems(response, operationName)
        .map((x) => serializers.deserializeWith(Food.serializer, x)));
  }
}

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import '../../models/food/edamam_food.dart';
import '../../models/serializers.dart';
import '../food/edamam_service.dart';
import 'food_repository.dart';

class EdamamFoodRepository implements FoodRepository {
  final EdamamService edamamService;

  EdamamFoodRepository({@required this.edamamService});

  /// Reform Edamam data to allow [Food] to be deserialized
  Map<String, dynamic> _reformFoodMap(Map<String, dynamic> data) {
    final reformedData = Map<String, dynamic>.from({
      'id': data['food']['foodId'],
      'name': data['food']['label'],
    });
    reformedData['measures'] = data['measures'];
    return reformedData;
  }

  @override
  Future<BuiltList<EdamamFood>> fetchQuery(String query) async {
    if (query.isEmpty) return <EdamamFood>[].build();
    final edamamData = await edamamService.searchFood(query);
    return BuiltList<EdamamFood>(
        edamamData.map((x) => serializers.deserializeWith(EdamamFood.serializer, _reformFoodMap(x))));
  }

  Future<EdamamFood> fetchItem(String id) async {
    final edamamData = await edamamService.getById(id);
    return serializers.deserializeWith(EdamamFood.serializer, _reformFoodMap(edamamData));
  }

  @override
  Stream<BuiltList<EdamamFood>> streamQuery(String query) => Stream.fromFuture(fetchQuery(query));
}

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import '../../models/food/edamam_food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../models/serializers.dart';
import '../food/edamam_service.dart';
import 'food_repository.dart';

bool _isValidMeasure(Map<String, dynamic> map) {
  final isValidWeight = map.containsKey('weight') && map['weight'] is num && map['weight'] > 0;
  final isValidLabel = map.containsKey('label') && map['label'] is String && map['label'].isNotEmpty;
  return isValidLabel && isValidWeight;
}

class EdamamFoodRepository implements FoodRepository {
  final EdamamService edamamService;

  EdamamFoodRepository({@required this.edamamService});

  /// Reform Edamam data to allow [Food] to be deserialized
  Map<String, dynamic> _reformFoodMap(Map<String, dynamic> data) {
    // Rename fields
    final reformedData = Map<String, dynamic>.from({
      'id': data['food']['foodId'],
      'name': data['food']['label'],
    });

    // Add measures
    final List<dynamic> measures = data['measures'];
    reformedData['measures'] = measures.map((m) => Map<String, dynamic>.from(m)).where(_isValidMeasure).toList();
    return reformedData;
  }

  @override
  Future<BuiltList<EdamamFood>> fetchQuery(String query) async {
    if (query.isEmpty) return <EdamamFood>[].build();
    final edamamData = await edamamService.searchFood(query) ?? [];
    return BuiltList<EdamamFood>(
        edamamData.map((x) => serializers.deserializeWith(EdamamFood.serializer, _reformFoodMap(x))));
  }

  Future<EdamamFood> fetchItem(EdamamFoodReference foodReference) async {
    final edamamData = await edamamService.getById(foodReference.id);
    final edamamFood = serializers.deserializeWith(EdamamFood.serializer, _reformFoodMap(edamamData));

    // Multiple edamam foods refer to the same database entry. Replace the generic label with the specific
    // one.
    return edamamFood.rebuild((b) => b.name = foodReference.name);
  }

  @override
  Stream<BuiltList<EdamamFood>> streamQuery(String query) => Stream.fromFuture(fetchQuery(query));
}

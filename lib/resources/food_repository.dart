import 'dart:async';
import 'dummy_data.dart';
import '../models/food.dart';

class FoodRepository {

  Future<List<Food>> fetchAllFoods() => Future(() => Dummy.foodList);

  Future<List<Food>> fetchQuery(String query) {
    return Future(() {
      if (query == '') {
        return fetchAllFoods();
      }
      return Dummy.foodList.where((f) => f.name.contains(query)).toList();
    });
  }

}
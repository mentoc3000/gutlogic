import 'dart:async';
import 'dummy_data.dart';
import 'package:gut_ai/models/food.dart';

class FoodRepository {
  Future<List<Food>> fetchAllFoods() => Future(() => Dummy.foodList);
}
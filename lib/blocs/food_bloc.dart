import '../resources/food_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/food.dart';

class FoodBloc {
  final _repository = FoodRepository();
  final _foodsController = StreamController<List<Food>>();

  Stream<List<Food>> get allFoods => _foodsController.stream;

  fetchAllFoods() async {
    List<Food> foods = await _repository.fetchAllFoods();
    _foodsController.sink.add(foods);
  }

  fetchQuery(String query) async {
    List<Food> foods = await _repository.fetchQuery(query);
    _foodsController.sink.add(foods);
  }

  dispose() {
    _foodsController.close();
  }
}

final bloc = FoodBloc();
import '../resources/food_repository.dart';
import 'package:rxdart/rxdart.dart';
import '../models/food.dart';

class FoodBloc {
  final _repository = FoodRepository();
  final _foodsFetcher = PublishSubject<List<Food>>();

  Observable<List<Food>> get allFoods => _foodsFetcher.stream;

  fetchAllMovies() async {
    List<Food> foods = await _repository.fetchAllFoods();
    _foodsFetcher.sink.add(foods);
  }

  dispose() {
    _foodsFetcher.close();
  }
}

final bloc = FoodBloc();
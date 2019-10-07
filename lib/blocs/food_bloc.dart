import '../resources/food_repository.dart';
import '../models/food.dart';
import 'searchable_bloc.dart';

class FoodBloc extends SearchableBloc<Food, FoodRepository> {
  FoodBloc(FoodRepository foodRepository) : super(foodRepository);
}

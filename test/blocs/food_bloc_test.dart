import 'dart:async';
import 'package:built_collection/src/list.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/resources/food_repository.dart';
import 'package:gut_ai/blocs/food_bloc.dart';
import 'package:gut_ai/blocs/searchable_event.dart';
import 'package:gut_ai/blocs/searchable_state.dart';

void main() {
  group('Food Bloc', () {
    FoodBloc foodBloc;
    MockFoodRepository foodRepository;
    Food _bread = Food(name: 'Bread');
    Food _water = Food(name: 'Water');
    BuiltList<Food> _allFoods = BuiltList([_bread, _water]);
    BuiltList<Food> _justWater = BuiltList([_water]);

    setUp(() {
      foodRepository = MockFoodRepository();
      when(foodRepository.fetchAll())
          .thenAnswer((i) => Future(() => _allFoods));
      when(foodRepository.fetchQuery('Water'))
          .thenAnswer((i) => Future(() => _justWater));
      foodBloc = FoodBloc(foodRepository);
    });

    test('initial state is Loading', () {
      expect(foodBloc.initialState, SearchableLoading());
    });

    test('fetches all foods', () {
      final List<SearchableState> expected = [
        SearchableLoading(),
        SearchableLoaded<Food>(_allFoods)
      ];

      expectLater(foodBloc.state, emitsInOrder(expected));

      foodBloc.dispatch(FetchAll());
    });

    test('fetches queried foods', () {
      final List<SearchableState> expected = [
        SearchableLoading(),
        SearchableLoaded<Food>(_justWater)
      ];

      expectLater(foodBloc.state, emitsInOrder(expected));

      foodBloc.dispatch(FetchQuery('Water'));
    });
  });
}

class MockFoodRepository extends Mock implements FoodRepository {}

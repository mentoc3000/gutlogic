import 'dart:async';
import 'package:built_collection/src/list.dart';
import 'package:flutter_test/flutter_test.dart' as prefix0;
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
    MockSearchableRepository searchableRepository;
    Food _bread = Food(name: 'Bread');
    Food _water = Food(name: 'Water');
    BuiltList<Food> _allFoods = BuiltList([_bread, _water]);
    BuiltList<Food> _justWater = BuiltList([_water]);

    setUp(() {
      searchableRepository = MockSearchableRepository();
      when(searchableRepository.fetchAll())
          .thenAnswer((i) => Future(() => _allFoods));
      when(searchableRepository.fetchQuery('Water'))
          .thenAnswer((i) => Future(() => _justWater));
      foodBloc = FoodBloc(searchableRepository);
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

class MockSearchableRepository extends Mock implements FoodRepository {}

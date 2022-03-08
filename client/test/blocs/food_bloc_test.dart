import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/food_search/food_search.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food/food.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import '../util/test_helpers.dart';
import 'food_bloc_test.mocks.dart';

@GenerateMocks([FoodService])
void main() {
  group('Food Bloc', () {
    late MockFoodService foodService;

    final bread = CustomFood(id: '123', name: 'Bread');
    final beer = CustomFood(id: '120', name: 'Beer');
    final bacon = EdamamFood(id: '987', name: 'Bacon');
    final bResults = BuiltList<Food>([bacon, beer, bread]);
    final brResults = BuiltList<Food>([bread]);

    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      foodService = MockFoodService();
      when(foodService.streamQuery('B')).thenAnswer((i) => Stream.value(bResults));
    });

    test('initial state', () {
      expect(FoodSearchBloc(foodService: foodService).state, FoodSearchLoading());
    });

    blocTest<FoodSearchBloc, FoodSearchState>(
      'creates custom food',
      build: () => FoodSearchBloc(foodService: foodService),
      act: (bloc) async => bloc.add(const CreateCustomFood('new food name')),
      verify: (bloc) async {
        verifyNamedParameter(foodService.add, 'name', 'new food name');
        verify(analyticsService.logEvent('create_custom_food')).called(1);
      },
    );

    blocTest<FoodSearchBloc, FoodSearchState>(
      'deletes custom food',
      build: () => FoodSearchBloc(foodService: foodService),
      act: (bloc) async => bloc.add(DeleteCustomFood(bread)),
      verify: (bloc) async {
        verify(foodService.delete(bread)).called(1);
        verify(analyticsService.logEvent('delete_custom_food')).called(1);
      },
    );

    blocTest<FoodSearchBloc, FoodSearchState>(
      'streams queried foods',
      build: () => FoodSearchBloc(foodService: foodService),
      act: (bloc) async => bloc.add(const StreamFoodQuery('B')),
      wait: debounceWaitDuration,
      expect: () => [FoodSearchLoading(), FoodSearchLoaded(query: 'B', items: bResults)],
      verify: (bloc) async {
        verify(foodService.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    blocTest<FoodSearchBloc, FoodSearchState>(
      'updates results when one source emits event',
      build: () {
        when(foodService.streamQuery('B')).thenAnswer((i) => Stream.fromIterable([bResults, brResults]));
        return FoodSearchBloc(foodService: foodService);
      },
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: () => [
        FoodSearchLoading(),
        FoodSearchLoaded(query: 'B', items: bResults),
        FoodSearchLoaded(query: 'B', items: brResults),
      ],
      verify: (bloc) async {
        verify(foodService.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    test('errors are recorded', () {
      // ignore: unnecessary_type_check
      expect(FoodSearchError(message: '') is ErrorRecorder, true);
    });
  });
}

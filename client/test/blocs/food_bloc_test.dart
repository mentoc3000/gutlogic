import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/food/food.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food/food.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
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

      when(foodService.fetchQuery('B')).thenAnswer((i) => Future<BuiltList<Food>>.value(bResults));
      when(foodService.streamQuery('B')).thenAnswer((i) => Stream.value(bResults));
    });

    test('initial state', () {
      expect(FoodBloc(foodService: foodService).state, FoodsLoading());
    });

    blocTest<FoodBloc, FoodState>(
      'creates custom food',
      build: () => FoodBloc(foodService: foodService),
      act: (bloc) async => bloc.add(const CreateCustomFood('new food name')),
      verify: (bloc) async {
        verifyNamedParameter(foodService.add, 'name', 'new food name');
        verify(analyticsService.logEvent('create_custom_food')).called(1);
      },
    );

    blocTest<FoodBloc, FoodState>(
      'deletes custom food',
      build: () => FoodBloc(foodService: foodService),
      act: (bloc) async => bloc.add(DeleteCustomFood(bread)),
      verify: (bloc) async {
        verify(foodService.delete(bread)).called(1);
        verify(analyticsService.logEvent('delete_custom_food')).called(1);
      },
    );

    blocTest<FoodBloc, FoodState>(
      'streams queried foods',
      build: () => FoodBloc(foodService: foodService),
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: () => [FoodsLoading(), FoodsLoaded(query: 'B', items: bResults)],
      verify: (bloc) async {
        verify(foodService.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    blocTest<FoodBloc, FoodState>(
      'updates results when one source emits event',
      build: () {
        when(foodService.streamQuery('B')).thenAnswer((i) => Stream.fromIterable([bResults, brResults]));
        return FoodBloc(foodService: foodService);
      },
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: () => [
        FoodsLoading(),
        FoodsLoaded(query: 'B', items: bResults),
        FoodsLoaded(query: 'B', items: brResults),
      ],
      verify: (bloc) async {
        verify(foodService.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    test('errors are recorded', () {
      expect(FoodError(message: '') is ErrorRecorder, true);
    });
  });
}

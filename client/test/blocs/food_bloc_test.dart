import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/food/food.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/resources/food/custom_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';
import '../util/test_helpers.dart';

void main() {
  group('Food Bloc', () {
    CustomFoodRepository customFoodRepository;
    EdamamFoodRepository edamamFoodRepository;
    final bread = CustomFood(id: '123', name: 'Bread');
    final beer = CustomFood(id: '120', name: 'Beer');
    final justBread = BuiltList<CustomFood>([bread]);
    final breadAndBeer = BuiltList<CustomFood>([bread, beer]);
    final bacon = EdamamFood(id: '987', name: 'Bacon');
    final justBacon = BuiltList<EdamamFood>([bacon]);
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      customFoodRepository = MockCustomFoodRepository();
      edamamFoodRepository = MockEdamamFoodRepository();

      when(customFoodRepository.fetchQuery('B')).thenAnswer((i) => Future<BuiltList<CustomFood>>.value(justBread));
      when(customFoodRepository.streamQuery('B')).thenAnswer((i) => Stream.value(justBread));

      when(edamamFoodRepository.fetchQuery('B')).thenAnswer((i) => Future<BuiltList<EdamamFood>>.value(justBacon));
      when(edamamFoodRepository.streamQuery('B')).thenAnswer((i) => Stream.value(justBacon));
    });

    test('initial state', () {
      expect(
        FoodBloc(
          customFoodRepository: customFoodRepository,
          edamamFoodRepository: edamamFoodRepository,
        ).state,
        FoodsLoading(),
      );
    });

    blocTest(
      'creates custom food',
      build: () {
        mockBlocDelegate();
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async => bloc.add(const CreateCustomFood('new food name')),
      verify: (bloc) async {
        verifyNamedParameter(customFoodRepository.add, 'name', 'new food name');
        verify(analyticsService.logEvent('create_custom_food')).called(1);
      },
    );

    blocTest(
      'deletes custom food',
      build: () {
        mockBlocDelegate();
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async => bloc.add(DeleteCustomFood(bread)),
      verify: (bloc) async {
        verify(customFoodRepository.delete(bread)).called(1);
        verify(analyticsService.logEvent('delete_custom_food')).called(1);
      },
    );

    blocTest(
      'streams queried foods',
      build: () {
        mockBlocDelegate();
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: [
        FoodsLoading(),
        FoodsLoaded(query: 'B', customFoods: justBread, edamamFoods: justBacon),
      ],
      verify: (bloc) async {
        verify(customFoodRepository.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    blocTest(
      'updates results when one source emits event',
      build: () {
        mockBlocDelegate();
        when(customFoodRepository.streamQuery('B')).thenAnswer((i) => Stream.fromIterable([justBread, breadAndBeer]));
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: [
        FoodsLoading(),
        FoodsLoaded(query: 'B', customFoods: justBread, edamamFoods: justBacon),
        FoodsLoaded(query: 'B', customFoods: breadAndBeer, edamamFoods: justBacon),
      ],
      verify: (bloc) async {
        verify(customFoodRepository.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    test('errors are recorded', () {
      expect(FoodError(message: '') is ErrorRecorder, true);
    });
  });
}

class MockCustomFoodRepository extends Mock implements CustomFoodRepository {}

class MockEdamamFoodRepository extends Mock implements EdamamFoodRepository {}

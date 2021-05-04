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
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import '../util/test_helpers.dart';
import 'food_bloc_test.mocks.dart';

@GenerateMocks([CustomFoodRepository, EdamamFoodRepository])
void main() {
  group('Food Bloc', () {
    late MockCustomFoodRepository customFoodRepository;
    late MockEdamamFoodRepository edamamFoodRepository;
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

    blocTest<FoodBloc, FoodState>(
      'creates custom food',
      build: () {
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async => bloc.add(const CreateCustomFood('new food name')),
      verify: (bloc) async {
        verifyNamedParameter(customFoodRepository.add, 'name', 'new food name');
        verify(analyticsService.logEvent('create_custom_food')).called(1);
      },
    );

    blocTest<FoodBloc, FoodState>(
      'deletes custom food',
      build: () {
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async => bloc.add(DeleteCustomFood(bread)),
      verify: (bloc) async {
        verify(customFoodRepository.delete(bread)).called(1);
        verify(analyticsService.logEvent('delete_custom_food')).called(1);
      },
    );

    blocTest<FoodBloc, FoodState>(
      'streams queried foods',
      build: () {
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: () => [
        FoodsLoading(),
        FoodsLoaded(query: 'B', customFoods: justBread, edamamFoods: justBacon),
      ],
      verify: (bloc) async {
        verify(customFoodRepository.streamQuery('B')).called(1);
        verify(analyticsService.logEvent('food_search')).called(1);
      },
    );

    blocTest<FoodBloc, FoodState>(
      'updates results when one source emits event',
      build: () {
        when(customFoodRepository.streamQuery('B')).thenAnswer((i) => Stream.fromIterable([justBread, breadAndBeer]));
        return FoodBloc(customFoodRepository: customFoodRepository, edamamFoodRepository: edamamFoodRepository);
      },
      act: (bloc) async {
        bloc.add(const StreamFoodQuery('B'));
      },
      wait: debounceWaitDuration,
      expect: () => [
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

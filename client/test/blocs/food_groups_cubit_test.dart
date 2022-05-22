import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/food_groups/food_groups.dart';
import 'package:gutlogic/resources/food_group_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'food_groups_cubit_test.mocks.dart';

@GenerateMocks([FoodGroupsRepository])
void main() {
  group('FoodGroupsCubit', () {
    final groups = {'Vegetables', 'Fruit'}.toBuiltSet();

    test('initial state', () {
      final repository = MockFoodGroupsRepository();
      when(repository.groups()).thenAnswer((_) => Future.value(groups));
      final bloc = FoodGroupsCubit(repository: repository);
      expect(bloc.state, const FoodGroupsLoading());
    });

    blocTest<FoodGroupsCubit, FoodGroupsState>(
      'update success',
      build: () {
        final repository = MockFoodGroupsRepository();
        when(repository.groups()).thenAnswer((_) => Future.value(groups));
        return FoodGroupsCubit(repository: repository);
      },
      expect: () => [FoodGroupsLoaded(groups: groups)],
    );
  });
}

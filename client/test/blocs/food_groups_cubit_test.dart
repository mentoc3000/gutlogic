import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/food_groups/food_groups.dart';
import 'package:gutlogic/models/food_group.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/resources/food_group_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'food_groups_cubit_test.mocks.dart';

@GenerateMocks([FoodGroupsRepository])
void main() {
  group('FoodGroupsCubit', () {
    final foodGroup = FoodGroup(
      name: 'Vegetables',
      foodRefs: BuiltSet.from([
        EdamamFoodReference(name: 'Green Beans', id: 'food1'),
        EdamamFoodReference(name: 'Lettuce', id: 'food2'),
      ]),
    );

    test('initial state', () {
      final repository = MockFoodGroupsRepository();
      when(repository.all()).thenAnswer((_) => Future.value([foodGroup]));
      final bloc = FoodGroupsCubit(repository: repository);
      expect(bloc.state, const FoodGroupsLoading());
    });

    blocTest<FoodGroupsCubit, FoodGroupsState>(
      'update success',
      build: () {
        final repository = MockFoodGroupsRepository();
        when(repository.all()).thenAnswer((_) => Future.value([foodGroup]));
        return FoodGroupsCubit(repository: repository);
      },
      expect: () => [
        FoodGroupsLoaded(foodGroups: [foodGroup])
      ],
    );
  });
}

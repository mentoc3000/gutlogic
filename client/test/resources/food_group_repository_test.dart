import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/resources/api_service.dart';
import 'package:gutlogic/resources/food_group_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'food_group_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('FoodGroupsRepository', () {
    final apiService = MockApiService();
    late FoodGroupsRepository repository;
    final foodGroups = {
      'Vegetables': [
        {
          'foodRef': {'\$': 'EdamamFoodReference', 'name': 'Green Beans', 'id': 'food1'},
          'doses': <String, double>{}
        },
      ],
      'Fruits': [
        {
          'foodRef': {'\$': 'EdamamFoodReference', 'name': 'Cherry', 'id': 'food2'},
          'doses': <String, double>{},
        }
      ]
    };

    setUp(() async {
      repository = FoodGroupsRepository(apiService: apiService);
      when(apiService.get(path: '/irritant/foodGroups')).thenAnswer((_) => Future.value({'data': foodGroups}));
    });

    test('groups', () async {
      final groups = await repository.groups();
      expect(groups.first, 'Vegetables');
      expect(groups.length, 2);
    });

    test('foods in group', () async {
      final foods = await repository.foods(group: 'Fruits');
      expect(foods.length, 1);
      expect(foods.first.foodRef.name, 'Cherry');
    });

    test('all foods', () async {
      final foods = await repository.foods();
      expect(foods.length, 2);
    });
  });
}

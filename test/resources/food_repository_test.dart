import 'dart:async';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:gut_ai/resources/food_repository.dart';
import 'package:gut_ai/resources/app_sync_service.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Food Repository', () {
    test('fetches all foods', () async {
      MockAppSyncService appSyncService = MockAppSyncService();
      final items = [
        {"name": "Orange Juice"},
        {"name": "Egg"}
      ];
      Map<String, dynamic> expected = {
        'data': {
          'listFoods': {'items': items}
        }
      };
      when(appSyncService.query('listFoods', 'listFoods { items { name } }'))
          .thenAnswer((i) => Future(() => expected));
      FoodRepository foodRepository = FoodRepository(appSyncService);
      List<Food> foods = await foodRepository.fetchAll();
      expect(foods, items.map((x) => serializers.deserializeWith(Food.serializer, x)).toList());
    });
  });
}

class MockAppSyncService extends Mock implements AppSyncService {}

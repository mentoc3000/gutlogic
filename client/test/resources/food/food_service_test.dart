import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/resources/food/custom_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'food_service_test.mocks.dart';

@GenerateMocks([CustomFoodRepository, EdamamFoodRepository])
void main() {
  group('FoodRepository', () {
    late MockCustomFoodRepository customFoodRepository;
    late MockEdamamFoodRepository edamamFoodRepository;
    late CustomFood customFood;
    late EdamamFood edamamFood;
    late FoodService foodService;

    setUp(() async {
      customFood = CustomFood(id: '7', name: 'Escargot');
      customFoodRepository = MockCustomFoodRepository();
      when(customFoodRepository.streamFood(customFood.toFoodReference())).thenAnswer((_) => Stream.value(customFood));
      when(customFoodRepository.fetchFood(customFood.toFoodReference())).thenAnswer((_) => Future.value(customFood));
      when(customFoodRepository.streamQuery(any)).thenAnswer((_) => Stream.value([customFood].build()));
      when(customFoodRepository.fetchQuery(any)).thenAnswer((_) => Future.value([customFood].build()));

      edamamFood = EdamamFood(id: '8', name: 'Toast Corners');
      edamamFoodRepository = MockEdamamFoodRepository();
      when(edamamFoodRepository.streamFood(edamamFood.toFoodReference())).thenAnswer((_) => Stream.value(edamamFood));
      when(edamamFoodRepository.fetchFood(edamamFood.toFoodReference())).thenAnswer((_) => Future.value(edamamFood));
      when(edamamFoodRepository.streamQuery(any)).thenAnswer((_) => Stream.value([edamamFood].build()));
      when(edamamFoodRepository.fetchQuery(any)).thenAnswer((_) => Future.value([edamamFood].build()));

      foodService = FoodService(
        edamamFoodRepository: edamamFoodRepository,
        customFoodRepository: customFoodRepository,
      );
    });

    test('streams foods', () async {
      final streamedCustomFood = foodService.streamFood(customFood.toFoodReference());
      await expectLater(streamedCustomFood, emits(customFood));

      final streamedEdamamFood = foodService.streamFood(edamamFood.toFoodReference());
      await expectLater(streamedEdamamFood, emits(edamamFood));
    });
  });
}

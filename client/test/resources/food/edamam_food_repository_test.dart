import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant/elementary_food.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:gutlogic/resources/local_storage.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'edamam_food_repository_test.mocks.dart';

@GenerateMocks([EdamamService, PantryService, LocalStorage, IrritantService])
void main() {
  group('EdamamFoodRepository', () {
    late EdamamFoodRepository foodRepository;
    late MockEdamamService edamamService;
    late MockLocalStorage localStorage;
    late MockIrritantService irritantService;
    final rice = EdamamFood(id: 'id1', name: 'rice', brand: 'Old Ben');
    final basicRice = rice.rebuild((b) => b.brand = null);
    final riceElementaryFood = ElementaryFood(
      names: BuiltList(['rice']),
      foodIds: BuiltList(['id1']),
      irritants: BuiltList(),
      canonical: rice.toFoodReference(),
    );
    final apples = [
      EdamamFood(id: 'id2', name: 'apple2'),
      EdamamFood(id: 'id3', name: 'apple3'),
      EdamamFood(id: 'id3', name: 'apple3'),
    ];

    setUp(() async {
      edamamService = MockEdamamService();
      when(edamamService.getById(any)).thenAnswer((_) => Future.value(null));
      when(edamamService.getById(rice.id)).thenAnswer((_) => Future.value(rice));
      when(edamamService.searchFood(any)).thenAnswer((_) => Future.value(<EdamamFood>[]));
      when(edamamService.searchFood('apple')).thenAnswer((_) => Future.value(apples));

      localStorage = MockLocalStorage();

      irritantService = MockIrritantService();

      foodRepository = EdamamFoodRepository(
        edamamService: edamamService,
        localStorage: localStorage,
        irritantService: irritantService,
      );
    });

    test('streames query', () async {
      final streamedFoods = foodRepository.streamQuery('apple');
      await expectLater(streamedFoods, emits(apples));
    });

    test('streames no foods for empty query', () async {
      final streamedFoods = foodRepository.streamQuery('');
      await expectLater(streamedFoods, emits(BuiltList<EdamamFood>([])));
    });

    test('streames no foods for matchless query', () async {
      final streamedFoods = foodRepository.streamQuery('tacos');
      await expectLater(streamedFoods, emits(BuiltList<EdamamFood>([])));
    });

    test('streames single food', () async {
      final streamedFood = foodRepository.streamFood(rice.toFoodReference());
      await expectLater(streamedFood, emits(rice));
    });

    test('reuses reference data for missing food', () async {
      final missingFoodRef = EdamamFoodReference(id: '007', name: 'Bond');
      final streamedFood = foodRepository.streamFood(missingFoodRef);
      final missingFood = EdamamFood(id: missingFoodRef.id, name: missingFoodRef.name);
      await expectLater(streamedFood, emits(missingFood));
    });

    test('reuses reference data for missing food stream', () async {
      final missingFoodRef = EdamamFoodReference(id: '007', name: 'Bond');
      final streamedFood = foodRepository.streamFood(missingFoodRef);
      final missingFood = EdamamFood(id: missingFoodRef.id, name: missingFoodRef.name);
      await expectLater(streamedFood, emits(missingFood));
    });

    test('fallback to local storage', () async {
      when(edamamService.getById(rice.id)).thenAnswer((_) => Future.value(null));
      when(localStorage.getEdamamFood(rice.id)).thenAnswer((_) => Future.value(rice));
      when(irritantService.getElementaryFood(rice.id)).thenAnswer((_) => Future.value(null));
      final streamedFood = foodRepository.streamFood(rice.toFoodReference());
      await expectLater(streamedFood, emits(basicRice));
    });

    test('fallback to elementary foods', () async {
      when(edamamService.getById(rice.id)).thenAnswer((_) => Future.value(null));
      when(localStorage.getEdamamFood(rice.id)).thenAnswer((_) => Future.value(null));
      when(irritantService.getElementaryFood(rice.id)).thenAnswer((_) => Future.value(riceElementaryFood));
      final streamedFood = foodRepository.streamFood(rice.toFoodReference());
      await expectLater(streamedFood, emits(basicRice));
    });

    test('fallback to food reference', () async {
      when(edamamService.getById(rice.id)).thenAnswer((_) => Future.value(null));
      when(localStorage.getEdamamFood(rice.id)).thenAnswer((_) => Future.value(null));
      when(irritantService.getElementaryFood(rice.id)).thenAnswer((_) => Future.value(null));
      final streamedFood = foodRepository.streamFood(rice.toFoodReference());
      await expectLater(streamedFood, emits(basicRice));
    });
  });
}

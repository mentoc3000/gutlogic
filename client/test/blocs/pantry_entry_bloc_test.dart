import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/pantry_entry/pantry_entry.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/preferences/preferences.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/resources/preferences_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'pantry_entry_bloc_test.mocks.dart';

@GenerateMocks([PantryService, FoodService, PreferencesService])
void main() {
  group('PantryEntryBloc', () {
    late MockPantryService repository;
    late MockFoodService foodService;
    late MockPreferencesService preferencesService;

    final irritants = [Irritant(name: 'GOS', concentration: 0.002, dosePerServing: 0.2)].toBuiltList();
    final food = EdamamFood(id: 'foodId', name: 'ham hock', irritants: irritants);
    final foodReference = food.toFoodReference();
    final pantryEntry = PantryEntry(
      userFoodDetailsId: food.id,
      foodReference: foodReference,
      sensitivity: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
      notes: 'Some notes',
    );
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockPantryService();
      when(repository.stream(pantryEntry)).thenAnswer((_) => Stream<PantryEntry>.fromIterable([pantryEntry]));

      foodService = MockFoodService();
      when(foodService.streamFood(any)).thenAnswer((_) => Stream<EdamamFood?>.value(null));
      when(foodService.streamFood(foodReference)).thenAnswer((_) => Stream.value(food));

      preferencesService = MockPreferencesService();
      when(preferencesService.stream).thenAnswer((_) => BehaviorSubject<Preferences>()..add(Preferences()));
      when(preferencesService.value).thenReturn(Preferences());
    });

    test('initial state', () {
      final bloc = PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      );
      expect(bloc.state, PantryEntryLoading(foodName: food.name));
    });

    blocTest<PantryEntryBloc, PantryEntryState>(
      'streams pantry entry with Edamam food',
      build: () {
        when(foodService.streamFood(foodReference)).thenAnswer((_) => Stream<EdamamFood>.value(food));
        return PantryEntryBloc(
          repository: repository,
          foodService: foodService,
          preferencesService: preferencesService,
          foodName: food.name,
        );
      },
      act: (bloc) => bloc.add(StreamEntry(pantryEntry)),
      expect: () => [
        PantryEntryLoading(foodName: food.name),
        PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()),
      ],
      verify: (bloc) {
        verify(repository.stream(pantryEntry)).called(1);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'does not debounce streaming',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) async {
        bloc.add(StreamEntry(pantryEntry));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(StreamEntry(pantryEntry));
      },
      expect: () => [
        PantryEntryLoading(foodName: food.name),
        PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()),
        PantryEntryLoading(foodName: food.name),
        PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()),
      ],
      verify: (bloc) {
        verify(repository.stream(pantryEntry)).called(2);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'creates and streams pantry entry',
      build: () {
        when(repository.addFood(any)).thenAnswer((_) => Stream.value(pantryEntry));
        return PantryEntryBloc(
          repository: repository,
          foodService: foodService,
          preferencesService: preferencesService,
          foodName: food.name,
        );
      },
      act: (bloc) => bloc.add(CreateAndStreamEntry(food.toFoodReference())),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        PantryEntryLoading(foodName: food.name),
        PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()),
      ],
      verify: (bloc) {
        verify(repository.addFood(foodReference)).called(1);
        verify(repository.stream(pantryEntry)).called(1);
        // verify(analyticsService.logEvent('create_pantry_entry')).called(1);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'loads pantryentry',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) => bloc.add(Load(pantryEntry: pantryEntry, food: null, excludedIrritants: BuiltSet())),
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: null, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verifyNever(repository.stream(pantryEntry));
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'does not debounce loading',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(Load(
            pantryEntry: pantryEntry.rebuild((b) => b.notes = 'asdf'),
            food: food,
            excludedIrritants: BuiltSet(),
          ));
      },
      expect: () => [
        PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()),
        PantryEntryLoaded(
          pantryEntry: pantryEntry.rebuild((b) => b.notes = 'asdf'),
          food: food,
          excludedIrritants: BuiltSet(),
        ),
      ],
      verify: (bloc) {
        verifyNever(repository.stream(pantryEntry));
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'deletes entry',
      build: () {
        return PantryEntryBloc(
          repository: repository,
          foodService: foodService,
          preferencesService: preferencesService,
          foodName: food.name,
        );
      },
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const Delete());
      },
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.delete(pantryEntry)).called(1);
        // verify(analyticsService.logEvent('delete_pantry_entry')).called(1);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'does not debounce deletion',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const Delete())
          ..add(const Delete());
      },
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.delete(pantryEntry)).called(2);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'updates notes',
      build: () {
        return PantryEntryBloc(
          repository: repository,
          foodService: foodService,
          preferencesService: preferencesService,
          foodName: food.name,
        );
      },
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const UpdateNotes('noted'));
      },
      wait: debounceWaitDuration,
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.updateNotes(pantryEntry, any)).called(1);
        // verify(analyticsService.logUpdateEvent('update_pantry_entry', 'notes')).called(1);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'debounces notes updates',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const UpdateNotes('noted'))
          ..add(const UpdateNotes('note'))
          ..add(const UpdateNotes('not'));
      },
      wait: debounceWaitDuration,
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.updateNotes(pantryEntry, 'not')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'updates sensitivity level',
      build: () {
        return PantryEntryBloc(
          repository: repository,
          foodService: foodService,
          preferencesService: preferencesService,
          foodName: food.name,
        );
      },
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.severe));
      },
      wait: debounceWaitDuration,
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.updateSensitivityLevel(pantryEntry, any)).called(1);
        // verify(analyticsService.logUpdateEvent('update_pantry_entry', 'sensitivity_level')).called(1);
      },
    );

    blocTest<PantryEntryBloc, PantryEntryState>(
      'debounces food updates',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.moderate))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.mild))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.moderate))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.severe));
      },
      wait: debounceWaitDuration,
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.updateSensitivityLevel(pantryEntry, SensitivityLevel.severe)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
    blocTest<PantryEntryBloc, PantryEntryState>(
      'maps multiple debounced events',
      build: () => PantryEntryBloc(
        repository: repository,
        foodService: foodService,
        preferencesService: preferencesService,
        foodName: food.name,
      ),
      act: (bloc) {
        bloc
          ..add(Load(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet()))
          ..add(const UpdateNotes('bad'))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.mild))
          ..add(const UpdateNotes('good'))
          ..add(const UpdateSensitivityLevel(SensitivityLevel.none));
      },
      wait: debounceWaitDuration,
      expect: () => [PantryEntryLoaded(pantryEntry: pantryEntry, food: food, excludedIrritants: BuiltSet())],
      verify: (bloc) {
        verify(repository.updateNotes(pantryEntry, any)).called(1);
        verify(repository.updateSensitivityLevel(pantryEntry, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test('errors are recorded', () {
      // ignore: unnecessary_type_check
      expect(PantryEntryError(message: '') is ErrorRecorder, true);
    });
  });
}

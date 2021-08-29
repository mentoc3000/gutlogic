import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'pantry_bloc_test.mocks.dart';

@GenerateMocks([PantryService])
void main() {
  group('PantryBloc', () {
    late MockPantryService pantryService;
    const pantryEntry1Id = 'entry1Id';
    final foodReference = CustomFoodReference(id: 'foodId', name: 'Corned Beef');
    final sensitivity = Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user);
    const notes = 'easy';
    final pantryEntry1 = PantryEntry(
      userFoodDetailsId: pantryEntry1Id,
      foodReference: foodReference,
      sensitivity: sensitivity,
      notes: notes,
    );
    const pantryEntry2Id = 'entry2Id';
    final pantryEntry2 = PantryEntry(
      userFoodDetailsId: pantryEntry2Id,
      foodReference: foodReference,
      sensitivity: sensitivity,
      notes: null,
    );
    final allPantryEntries = BuiltList<PantryEntry>([pantryEntry1, pantryEntry2]);

    setUp(() {
      pantryService = MockPantryService();
      when(pantryService.streamAll())
          .thenAnswer((_) => Stream<BuiltList<PantryEntry>>.fromIterable([allPantryEntries]));
    });

    test('initial state', () {
      expect(PantryBloc(pantryService: pantryService).state, PantryLoading());
    });

    blocTest<PantryBloc, PantryState>(
      'streams all pantry entries',
      build: () => PantryBloc(pantryService: pantryService),
      act: (bloc) async => bloc.add(const StreamAllPantry()),
      expect: () => [PantryLoading(), PantryLoaded(allPantryEntries)],
      verify: (bloc) {
        verify(pantryService.streamAll()).called(1);
      },
    );

    blocTest<PantryBloc, PantryState>(
      'loads pantry entries',
      build: () => PantryBloc(pantryService: pantryService),
      act: (bloc) async => bloc.add(LoadPantry(items: allPantryEntries)),
      expect: () => [PantryLoaded(allPantryEntries)],
      verify: (bloc) {
        verifyNever(pantryService.streamAll());
      },
    );

    blocTest<PantryBloc, PantryState>(
      'deletes entry',
      build: () => PantryBloc(pantryService: pantryService),
      act: (bloc) async => bloc.add(DeletePantryEntry(pantryEntry2)),
      expect: () => [PantryEntryDeleted(pantryEntry2)],
      verify: (bloc) {
        verify(pantryService.delete(pantryEntry2)).called(1);
      },
    );

    blocTest<PantryBloc, PantryState>(
      'transitions to error state when stream throws error',
      build: () {
        when(pantryService.streamAll()).thenThrow(Exception());
        return PantryBloc(pantryService: pantryService);
      },
      act: (bloc) async => bloc.add(const StreamAllPantry()),
      expect: () => [PantryLoading(), isA<PantryError>()],
    );

    test('errors are recorded', () {
      expect(PantryError(message: '') is ErrorRecorder, true);
    });
  });
}

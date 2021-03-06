import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('PantryBloc', () {
    PantryRepository pantryRepository;
    const pantryEntry1Id = 'entry1Id';
    final foodReference = CustomFoodReference(id: 'foodId', name: 'Corned Beef');
    const sensitivity = Sensitivity.moderate;
    const notes = 'easy';
    final pantryEntry1 = PantryEntry(
      id: pantryEntry1Id,
      foodReference: foodReference,
      sensitivity: sensitivity,
      notes: notes,
    );
    const pantryEntry2Id = 'entry2Id';
    final pantryEntry2 = PantryEntry(
      id: pantryEntry2Id,
      foodReference: foodReference,
      sensitivity: sensitivity,
      notes: null,
    );
    final allPantryEntries = BuiltList<PantryEntry>([pantryEntry1, pantryEntry2]);

    setUp(() {
      pantryRepository = MockPantryRepository();
      when(pantryRepository.streamAll())
          .thenAnswer((_) => Stream<BuiltList<PantryEntry>>.fromIterable([allPantryEntries]));
    });

    test('initial state', () {
      expect(PantryBloc(repository: pantryRepository).state, PantryLoading());
    });

    blocTest(
      'streams all pantry entries',
      build: () => PantryBloc(repository: pantryRepository),
      act: (bloc) async => bloc.add(const StreamAllPantry()),
      expect: [PantryLoading(), PantryLoaded(allPantryEntries)],
      verify: (bloc) {
        verify(pantryRepository.streamAll()).called(1);
      },
    );

    blocTest(
      'loads pantry entries',
      build: () => PantryBloc(repository: pantryRepository),
      act: (bloc) async => bloc.add(LoadPantry(items: allPantryEntries)),
      expect: [PantryLoaded(allPantryEntries)],
      verify: (bloc) {
        verifyNever(pantryRepository.streamAll());
      },
    );

    blocTest(
      'deletes entry',
      build: () => PantryBloc(repository: pantryRepository),
      act: (bloc) async => bloc.add(DeletePantryEntry(pantryEntry2)),
      expect: [PantryEntryDeleted(pantryEntry2)],
      verify: (bloc) {
        verify(pantryRepository.delete(pantryEntry2)).called(1);
      },
    );

    blocTest(
      'transitions to error state when stream throws error',
      build: () {
        when(pantryRepository.streamAll()).thenThrow(Exception());
        return PantryBloc(repository: pantryRepository);
      },
      act: (bloc) async => bloc.add(const StreamAllPantry()),
      expect: [PantryLoading(), isA<PantryError>()],
    );

    test('errors are recorded', () {
      expect(PantryError(message: '') is ErrorRecorder, true);
    });
  });
}

class MockPantryRepository extends Mock implements PantryRepository {}

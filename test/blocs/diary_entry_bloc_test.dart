import 'dart:async';
import 'package:built_collection/src/list.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:gut_ai/models/bowel_movement.dart';
import 'package:gut_ai/models/meal.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/resources/diary_entry_repository.dart';
import 'package:gut_ai/blocs/diary_entry_bloc.dart';
import 'package:gut_ai/blocs/database_event.dart';
import 'package:gut_ai/blocs/database_state.dart';
import 'package:gut_ai/resources/id_service.dart';

void main() {
  group('DiaryEntry Bloc', () {
    DiaryEntryBloc diaryEntryBloc;
    MockDiaryEntryRepository diaryEntryRepository;
    DiaryEntry _meal = MealEntry(
      id: '1',
      userId: 'user',
      creationDate: DateTime.now(),
      modificationDate: DateTime.now(),
      dateTime: DateTime.now(),
      meal: Meal(ingredients: BuiltList([])),
      notes: 'Breakfast',
    );
    DiaryEntry _bowelMovement = BowelMovementEntry(
      id: '2',
      userId: 'user',
      creationDate: DateTime.now(),
      modificationDate: DateTime.now(),
      dateTime: DateTime.now(),
      bowelMovement: BowelMovement(volume: 3, type: 4),
      notes: 'Better than yesterday',
    );
    BuiltList<DiaryEntry> _allDiaryEntrys = BuiltList([_meal, _bowelMovement]);
    MockIdService idService;

    setUp(() {
      diaryEntryRepository = MockDiaryEntryRepository();
      when(diaryEntryRepository.fetchAll())
          .thenAnswer((i) => Future.value(_allDiaryEntrys));

      idService = MockIdService();
      when(idService.getId()).thenReturn('id');
      when(idService.getUserId()).thenReturn('userId');

      diaryEntryBloc = DiaryEntryBloc(diaryEntryRepository, idService);
    });

    test('initial state is Loading', () {
      expect(diaryEntryBloc.initialState, DatabaseLoading());
    });

    test('creates meal entry', () {
      MealEntry mealEntry = diaryEntryBloc.newMealEntry();
      expect(mealEntry.id, 'id');
    });

    test('fetches all diary entries', () {
      final List<DatabaseState> expected = [
        DatabaseLoading(),
        DatabaseLoaded<DiaryEntry>(_allDiaryEntrys)
      ];

      expectLater(diaryEntryBloc.state, emitsInOrder(expected));

      diaryEntryBloc.dispatch(FetchAll());
    });

    test('inserts entry', () async {
      DiaryEntry meal2 = MealEntry(
        id: '1',
        userId: 'user',
        creationDate: DateTime.now(),
        modificationDate: DateTime.now(),
        dateTime: DateTime.now(),
        meal: Meal(ingredients: BuiltList([])),
        notes: 'Lunch',
      );

      diaryEntryBloc.dispatch(Insert(meal2));

      await untilCalled(diaryEntryRepository.insert(any));
      verify(diaryEntryRepository.insert(meal2));
    });

    test('deletes entry', () async {
      String id = '12345';

      diaryEntryBloc.dispatch(Delete(id));

      await untilCalled(diaryEntryRepository.delete(any));
      verify(diaryEntryRepository.delete(id));
    });

    test('upserts entry', () async {
      DiaryEntry meal2 = MealEntry(
        id: '1',
        userId: 'user',
        creationDate: DateTime.now(),
        modificationDate: DateTime.now(),
        dateTime: DateTime.now(),
        meal: Meal(ingredients: BuiltList([])),
        notes: 'Lunch',
      );

      diaryEntryBloc.dispatch(Update(meal2));

      await untilCalled(diaryEntryRepository.update(any));
      verify(diaryEntryRepository.update(meal2));
    });
  });
}

class MockDiaryEntryRepository extends Mock implements DiaryEntryRepository {}

class MockIdService extends Mock implements IdService {}

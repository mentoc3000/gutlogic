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

void main() {
  group('DiaryEntry Bloc', () {
    DiaryEntryBloc foodBloc;
    MockDiaryEntryRepository diaryEntryRepository;
    DiaryEntry _meal = MealEntry(
      dateTime: DateTime.now(),
      meal: Meal(ingredients: BuiltList([])),
      notes: 'Breakfast',
    );
    DiaryEntry _bowelMovement = BowelMovementEntry(
      dateTime: DateTime.now(),
      bowelMovement: BowelMovement(volume: 3, type: 4),
      notes: 'Better than yesterday',
    );
    BuiltList<DiaryEntry> _allDiaryEntrys = BuiltList([_meal, _bowelMovement]);

    setUp(() {
      diaryEntryRepository = MockDiaryEntryRepository();
      when(diaryEntryRepository.fetchAll())
          .thenAnswer((i) => Future(() => _allDiaryEntrys));
      foodBloc = DiaryEntryBloc(diaryEntryRepository);
    });

    test('initial state is Loading', () {
      expect(foodBloc.initialState, DatabaseLoading());
    });

    test('fetches all diary entries', () {
      final List<DatabaseState> expected = [
        DatabaseLoading(),
        DatabaseLoaded<DiaryEntry>(_allDiaryEntrys)
      ];

      expectLater(foodBloc.state, emitsInOrder(expected));

      foodBloc.dispatch(FetchAll());
    });

    test('inserts entry', () {
      DiaryEntry meal2 = MealEntry(
        dateTime: DateTime.now(),
        meal: Meal(ingredients: BuiltList([])),
        notes: 'Lunch',
      );
      final List<DatabaseState> expected = [
        DatabaseLoading(),
        DatabaseLoaded<DiaryEntry>(
            _allDiaryEntrys.rebuild((b) => b..add(meal2)))
      ];

      expectLater(foodBloc.state, emitsInOrder(expected));

      foodBloc.dispatch(Insert(meal2));
      foodBloc.dispatch(FetchAll());
    });
  });
}

class MockDiaryEntryRepository extends Mock implements DiaryEntryRepository {}

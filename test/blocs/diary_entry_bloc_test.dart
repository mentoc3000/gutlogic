import 'dart:async';
import 'package:built_collection/src/list.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/resources/diary_entry_repository.dart';
import 'package:gut_ai/blocs/diary_entry_bloc.dart';
import 'package:gut_ai/blocs/database_event.dart';
import 'package:gut_ai/blocs/database_state.dart';

void main() {
  group('DiaryEntry Bloc', () {
    DiaryEntryBloc foodBloc;
    MockDiaryEntryRepository diaryEntryRepository;
    DiaryEntry _meal = MealEntry();
    DiaryEntry _bowelMovement = BowelMovementEntry();
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

    test('fetches all foods', () {
      final List<DatabaseState> expected = [
        DatabaseLoading(),
        DatabaseLoaded<DiaryEntry>(_allDiaryEntrys)
      ];

      expectLater(foodBloc.state, emitsInOrder(expected));

      foodBloc.dispatch(FetchAll());
    });
  });
}

class MockDiaryEntryRepository extends Mock implements DiaryEntryRepository {}

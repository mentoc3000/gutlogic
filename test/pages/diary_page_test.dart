import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/meal.dart';
import 'package:mockito/mockito.dart';
import 'package:built_collection/built_collection.dart';

import 'package:gut_ai/pages/diary_page.dart';
import 'package:gut_ai/blocs/diary_entry_bloc.dart';
import 'package:gut_ai/blocs/database_state.dart';
import 'package:gut_ai/models/diary_entry.dart';

class MockDiaryEntryBloc extends Mock implements DiaryEntryBloc {}

void main() {
  DiaryEntryBloc diaryEntryBloc;

  setUp(() {
    diaryEntryBloc = MockDiaryEntryBloc();
  });

  group('DiaryPage', () {
    testWidgets('shows loading', (WidgetTester tester) async {
      when(diaryEntryBloc.currentState).thenAnswer((_) => DatabaseLoading());

      Widget diaryPage = BlocProvider(
        bloc: diaryEntryBloc,
        child: MaterialApp(
          home: DiaryPage(),
        ),
      );

      await tester.pumpWidget(diaryPage);
      // await tester.pump(Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows entry', (WidgetTester tester) async {
      when(diaryEntryBloc.currentState).thenAnswer(
          (_) => DatabaseLoaded<DiaryEntry>(BuiltList<DiaryEntry>([
            MealEntry(
              id: 'meal1',
              userId: 'user',
              creationDate: DateTime(2019,3,4,12,30),
              modificationDate: DateTime(2019,3,5,4,30),
              dateTime: DateTime(2019,3,4,12,0),
              meal: Meal(ingredients: BuiltList([])),
              notes: 'notes',
            )
          ])));

      Widget diaryPage = BlocProvider(
        bloc: diaryEntryBloc,
        child: MaterialApp(
          home: DiaryPage(),
        ),
      );

      await tester.pumpWidget(diaryPage);
      // await tester.pump(Duration(seconds: 1));
      expect(find.text('Mon, Mar 4'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
    });

    testWidgets('shows error', (WidgetTester tester) async {
      when(diaryEntryBloc.currentState).thenAnswer((_) => DatabaseError());

      Widget diaryPage = BlocProvider(
        bloc: diaryEntryBloc,
        child: MaterialApp(
          home: DiaryPage(),
        ),
      );

      await tester.pumpWidget(diaryPage);
      // await tester.pump(Duration(seconds: 1));
      expect(find.text('Error'), findsOneWidget);
    });
  });
}

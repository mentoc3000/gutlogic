import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/pages/diary/diary_page.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import '../mocks/mock_page_route.dart';
import '../mocks/mock_router.dart';

class MockDiaryBloc extends MockBloc<DiaryEvent, DiaryState> implements DiaryBloc {}

class DiaryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: DiaryPage());
}

Future<void> scrollToTop(WidgetTester tester) async {
  await tester.dragFrom(const Offset(300, 200), const Offset(0, 1000));
  await tester.pumpAndSettle();
}

void main() {
  DiaryBloc diaryBloc;
  Widget diaryPage;
  Routes routes;

  initializeTimeZones();

  setUp(() {
    routes = MockRoutes();
    diaryBloc = MockDiaryBloc();
    diaryPage = Provider<Routes>.value(
      value: routes,
      child: BlocProvider<DiaryBloc>.value(
        value: diaryBloc,
        child: DiaryPageWrapper(),
      ),
    );
  });

  group('DiaryPage', () {
    testWidgets('shows empty diary', (WidgetTester tester) async {
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[].build()));
      await tester.pumpWidget(diaryPage);
      expect(find.text('Timeline'), findsOneWidget);
      verifyNever(diaryBloc.add(any));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      when(diaryBloc.state).thenReturn(DiaryLoading());
      await tester.pumpWidget(diaryPage);
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(diaryBloc.add(any));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      when(diaryBloc.state).thenReturn(DiaryError(message: message));
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      verifyNever(diaryBloc.add(any));
    });

    testWidgets('removes meal entry when dragging diary entry tile left', (WidgetTester tester) async {
      final mealEntry = MealEntry(
        id: 'meal1',
        datetime: DateTime(2019, 3, 4, 11, 23),
        mealElements: BuiltList<MealElement>([]),
      );
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[mealEntry].build()));
      await tester.pumpWidget(diaryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final entryTile = find.text('Meal/Snack');
      expect(entryTile, findsOneWidget);
      await tester.fling(entryTile, const Offset(-500, 0), 1e3);
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(entryTile, findsNothing);
      verify(diaryBloc.add(Delete(mealEntry))).called(1);
    });

    testWidgets('shows an undo snackbar after deleting an entry', (WidgetTester tester) async {
      final mealEntry = MealEntry(
        id: 'meal1',
        datetime: DateTime(2019, 3, 4, 11, 23),
        mealElements: BuiltList<MealElement>([]),
      );
      whenListen(
          diaryBloc,
          Stream.fromIterable([
            DiaryLoaded(<DiaryEntry>[mealEntry].build()),
            DiaryEntryDeleted(mealEntry),
          ]));
      await tester.pumpWidget(diaryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('does nothing when dragging diary entry tile right', (WidgetTester tester) async {
      final mealEntry = MealEntry(
        id: 'meal1',
        datetime: DateTime(2019, 3, 4, 11, 23),
        mealElements: BuiltList<MealElement>([]),
      );
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[mealEntry].build()));
      await tester.pumpWidget(diaryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final entryTile = find.text('Meal/Snack');
      expect(entryTile, findsOneWidget);
      await tester.drag(entryTile, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(entryTile, findsOneWidget);
      verifyNever(diaryBloc.add(Delete(mealEntry)));
    });

    testWidgets('always shows today', (WidgetTester tester) async {
      final today = DateTime.now();
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[].build()));
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();

      final dateFormatter = DateFormat.MMMEd();
      final todayString = dateFormatter.format(today.toLocal());
      expect(find.text(todayString), findsOneWidget);
      expect(find.text('No Entries'), findsNothing);
    });

    testWidgets('start at today', (WidgetTester tester) async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayMealEntry = MealEntry(
        id: 'meal1',
        datetime: yesterday,
        mealElements: BuiltList<MealElement>([]),
      );
      final todayMealEntry = MealEntry(
        id: 'meal1',
        datetime: today,
        mealElements: BuiltList<MealElement>([]),
      );
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[
        ...List<MealEntry>.filled(5, yesterdayMealEntry),
        ...List<MealEntry>.filled(5, todayMealEntry),
      ].build()));
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();

      final dateFormatter = DateFormat.MMMEd();
      final todayString = dateFormatter.format(today.toLocal());
      final yesterdayString = dateFormatter.format(yesterday.toLocal());
      expect(find.text(yesterdayString), findsNothing);
      expect(find.text(todayString), findsOneWidget);
      expect(find.text('No Entries'), findsNothing);
    });

    testWidgets('uses local time', (WidgetTester tester) async {
      final detroit = getLocation('America/Detroit');
      setLocalLocation(detroit);
      final datetime = TZDateTime(detroit, 2020, 1, 4, 22, 1);
      final todayMealEntry = MealEntry(
        id: 'meal1',
        datetime: datetime,
        mealElements: BuiltList<MealElement>([]),
      );
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[todayMealEntry].build()));
      await tester.pumpWidget(diaryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      // Local date in header
      final headerDateFormatter = DateFormat.MMMEd();
      final localTodayHeaderString = headerDateFormatter.format(datetime);
      final utcTodayHeaderString = headerDateFormatter.format(datetime.toUtc());
      assert(localTodayHeaderString != utcTodayHeaderString);
      expect(find.text(localTodayHeaderString), findsOneWidget);

      // Local time in tile
      final timeFormatter = DateFormat.jm();
      final localTodayString = timeFormatter.format(datetime);
      final utcTodayString = timeFormatter.format(datetime.toUtc());
      assert(localTodayString != utcTodayString);
      expect(find.text(localTodayString), findsOneWidget);
      expect(find.text(utcTodayString), findsNothing);
    });

    testWidgets('indicates gaps in diary', (WidgetTester tester) async {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final lastMonth = lastWeek.subtract(const Duration(days: 30));
      final lastMonthMealEntry = MealEntry(
        id: 'meal1',
        datetime: lastMonth,
        mealElements: BuiltList<MealElement>([]),
      );
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[
        ...List<MealEntry>.filled(2, lastMonthMealEntry),
      ].build()));
      await tester.pumpWidget(diaryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      expect(find.text('No Entries'), findsOneWidget);
    });

    testWidgets('aligns color bars', (WidgetTester tester) async {
      final morning = DateTime(2020, 1, 1, 6, 11, 0);
      final afternoon = DateTime(2020, 1, 1, 12, 36, 0);
      final morningMealEntry = MealEntry(
        id: 'meal1',
        datetime: morning,
        mealElements: BuiltList<MealElement>([]),
      );
      final afternoonMealEntry = MealEntry(
        id: 'meal2',
        datetime: afternoon,
        mealElements: BuiltList<MealElement>([]),
      );
      when(diaryBloc.state).thenReturn(DiaryLoaded(<DiaryEntry>[morningMealEntry, afternoonMealEntry].build()));
      await tester.pumpWidget(diaryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final morningTitle = (find.byType(ListTile).first.evaluate().single.widget as ListTile).title;
      final afternoonTitle = (find.byType(ListTile).last.evaluate().single.widget as ListTile).title;
      final morningDx = tester.getBottomLeft(find.byWidget(morningTitle)).dx;
      final afternoonDx = tester.getBottomLeft(find.byWidget(afternoonTitle)).dx;
      expect(morningDx, afternoonDx);
    });

    group('meal entry', () {
      setUp(() {
        final mealEntry = MealEntry(
          id: 'meal1',
          datetime: DateTime(2019, 3, 4, 11, 23),
          mealElements: BuiltList<MealElement>([]),
          notes: 'notes',
        );
        when(diaryBloc.state).thenReturn(DiaryLoaded(BuiltList<DiaryEntry>([mealEntry])));
      });

      testWidgets('shows tile', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await scrollToTop(tester);
        await tester.pumpAndSettle();
        expect(find.text('Mon, Mar 4'), findsOneWidget);
        expect(find.text('11:23 AM'), findsOneWidget);
        expect(find.text('Meal/Snack'), findsOneWidget);
      });

      testWidgets('tile routes to page', (WidgetTester tester) async {
        final navigationKey = UniqueKey();

        when(routes.createMealEntryRoute(entry: anyNamed('entry'))).thenReturn(MockPageRoute(key: navigationKey));

        await tester.pumpWidget(diaryPage);
        await scrollToTop(tester);
        await tester.pumpAndSettle();

        final tappable = find.text('Meal/Snack');
        await tester.tap(tappable);
        await tester.pumpAndSettle();
        expect(find.byKey(navigationKey), findsOneWidget);
      });
    });

    group('bowel movement entry', () {
      setUp(() {
        final bowelMovementEntry = BowelMovementEntry(
          id: 'bm1',
          datetime: DateTime(2019, 3, 4, 11, 23),
          bowelMovement: BowelMovement(volume: 3, type: 4),
          notes: 'notes',
        );
        when(diaryBloc.state).thenReturn(DiaryLoaded(BuiltList<DiaryEntry>([bowelMovementEntry])));
      });

      testWidgets('shows bowel movement entry', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await scrollToTop(tester);
        await tester.pumpAndSettle();
        expect(find.text('Mon, Mar 4'), findsOneWidget);
        expect(find.text('11:23 AM'), findsOneWidget);
        expect(find.text('Bowel Movement'), findsOneWidget);
      });

      testWidgets('tile routes to page', (WidgetTester tester) async {
        final navigationKey = UniqueKey();

        when(routes.createBowelMovementEntryRoute(entry: anyNamed('entry')))
            .thenReturn(MockPageRoute(key: navigationKey));

        await tester.pumpWidget(diaryPage);
        await scrollToTop(tester);
        await tester.pumpAndSettle();

        final tappable = find.text('Bowel Movement');
        await tester.tap(tappable);
        await tester.pumpAndSettle();
        expect(find.byKey(navigationKey), findsOneWidget);
      });
    });

    group('symptom entry', () {
      const symptomName = 'Gas';

      setUp(() {
        final symptomEntry = SymptomEntry(
          id: 'symptom1',
          datetime: DateTime(2019, 3, 4, 11, 23),
          symptom:
              Symptom(symptomType: SymptomType(id: 'symptomType1', name: symptomName), severity: Severity.moderate),
          notes: 'notes',
        );
        when(diaryBloc.state).thenReturn(DiaryLoaded(BuiltList<DiaryEntry>([symptomEntry])));
      });

      testWidgets('shows symptom entry', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await scrollToTop(tester);
        await tester.pumpAndSettle();
        expect(find.text('Mon, Mar 4'), findsOneWidget);
        expect(find.text('11:23 AM'), findsOneWidget);
        expect(find.text(symptomName), findsOneWidget);
      });

      testWidgets('tile routes to page', (WidgetTester tester) async {
        final navigationKey = UniqueKey();

        when(routes.createSymptomEntryRoute(entry: anyNamed('entry'))).thenReturn(MockPageRoute(key: navigationKey));

        await tester.pumpWidget(diaryPage);
        await scrollToTop(tester);
        await tester.pumpAndSettle();

        final tappable = find.text(symptomName);
        await tester.tap(tappable);
        await tester.pumpAndSettle();
        expect(find.byKey(navigationKey), findsOneWidget);
      });
    });

    group('floating action button', () {
      setUp(() {
        when(diaryBloc.state).thenReturn(DiaryLoaded(BuiltList<DiaryEntry>([])));
      });

      testWidgets('shows speed dial', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();

        final fab = find.byType(SpeedDial);
        expect(fab, findsOneWidget);
      });
    });
  });
}

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
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/pages/diary/diary_page.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/routes/routes.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import '../mocks/mock_page_route.dart';
import '../mocks/mock_router.dart';

class MockDiaryBloc extends MockBloc<DiaryEvent, DiaryState> implements DiaryBloc {}

class MockDiaryRepository extends Mock implements DiaryRepository {}

class MockSensitivityService extends Mock implements SensitivityService {}

class DiaryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: DiaryPage());
}

Future<void> scrollToTop(WidgetTester tester) async {
  await tester.dragFrom(const Offset(300, 200), const Offset(0, 1000));
  await tester.pumpAndSettle();
}

void main() {
  late DiaryBloc diaryBloc;
  late SensitivityService sensitivityService;
  late Widget diaryPage;
  late Routes routes;

  final mealEntry = MealEntry(
    id: 'meal1',
    datetime: DateTime(2019, 3, 4, 11, 23),
    mealElements: BuiltList<MealElement>([]),
  );

  initializeTimeZones();

  setUp(() {
    routes = MockRoutes();

    diaryBloc = MockDiaryBloc();
    when(() => diaryBloc.repository).thenReturn(MockDiaryRepository());

    sensitivityService = MockSensitivityService();
    when(() => sensitivityService.of(any())).thenReturn(Sensitivity.unknown);
    when(() => sensitivityService.aggregate(any())).thenReturn(Sensitivity.unknown);

    diaryPage = Provider<Routes>.value(
      value: routes,
      child: BlocProvider<DiaryBloc>.value(
        value: diaryBloc,
        child: ChangeNotifierProvider.value(
          value: sensitivityService,
          child: DiaryPageWrapper(),
        ),
      ),
    );
  });

  group('DiaryPage', () {
    testWidgets('shows empty diary', (WidgetTester tester) async {
      final diaryState = DiaryLoaded(<DiaryEntry>[].build());
      whenListen(diaryBloc, Stream.value(diaryState), initialState: DiaryLoading());
      await tester.pumpWidget(diaryPage);
      expect(find.text('Timeline'), findsOneWidget);
      verifyNever(() => diaryBloc.add(any()));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      whenListen(diaryBloc, Stream.value(DiaryLoading()), initialState: DiaryLoading());
      await tester.pumpWidget(diaryPage);
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(() => diaryBloc.add(any()));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(diaryBloc, Stream.value(DiaryError(message: message)), initialState: DiaryLoading());
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      verifyNever(() => diaryBloc.add(any()));
    });

    testWidgets('removes meal entry when dragging diary entry tile left', (WidgetTester tester) async {
      final diaryState = DiaryLoaded(<DiaryEntry>[mealEntry].build());
      whenListen(diaryBloc, Stream.value(diaryState), initialState: DiaryLoading());
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
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
      verify(() => diaryBloc.add(Delete(mealEntry))).called(1);
    });

    testWidgets('shows an undo snackbar after deleting an entry', (WidgetTester tester) async {
      whenListen(
          diaryBloc,
          Stream.fromIterable([
            DiaryLoaded(<DiaryEntry>[mealEntry].build()),
            DiaryEntryDeleted(mealEntry),
          ]),
          initialState: DiaryLoading());
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('does nothing when dragging diary entry tile right', (WidgetTester tester) async {
      whenListen(
        diaryBloc,
        Stream.value(DiaryLoaded(<DiaryEntry>[mealEntry].build())),
        initialState: DiaryLoading(),
      );
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final entryTile = find.text('Meal/Snack');
      expect(entryTile, findsOneWidget);
      await tester.drag(entryTile, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(entryTile, findsOneWidget);
      verifyNever(() => diaryBloc.add(Delete(mealEntry)));
    });

    testWidgets('always shows today', (WidgetTester tester) async {
      final today = DateTime.now();
      whenListen(
        diaryBloc,
        Stream.value(DiaryLoaded(<DiaryEntry>[].build())),
        initialState: DiaryLoading(),
      );
      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();

      final dateFormatter = DateFormat.MMMEd();
      final todayString = dateFormatter.format(today.toLocal());
      expect(find.text(todayString), findsOneWidget);
      expect(find.text('No Entries'), findsNothing);
    });

    testWidgets('start at today', (WidgetTester tester) async {
      final today = DateTime.now();
      final todayMealEntry = MealEntry(
        id: 'meal1',
        datetime: today,
        mealElements: BuiltList<MealElement>([]),
      );

      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayMealEntry = MealEntry(
        id: 'meal1',
        datetime: yesterday,
        mealElements: BuiltList<MealElement>([]),
      );

      final diaryEntries = <DiaryEntry>[
        ...List.filled(5, yesterdayMealEntry),
        ...List.filled(5, todayMealEntry),
      ].build();

      whenListen(
        diaryBloc,
        Stream.value(DiaryLoaded(diaryEntries)),
        initialState: DiaryLoading(),
      );
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
      whenListen(
        diaryBloc,
        Stream.value(DiaryLoaded(<DiaryEntry>[todayMealEntry].build())),
        initialState: DiaryLoading(),
      );

      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
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

      final diaryEntries = List<DiaryEntry>.filled(2, lastMonthMealEntry).build();

      whenListen(
        diaryBloc,
        Stream.value(DiaryLoaded(diaryEntries)),
        initialState: DiaryLoading(),
      );

      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
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

      final diaryEntries = <DiaryEntry>[morningMealEntry, afternoonMealEntry].build();

      whenListen(
        diaryBloc,
        Stream.value(DiaryLoaded(diaryEntries)),
        initialState: DiaryLoading(),
      );

      await tester.pumpWidget(diaryPage);
      await tester.pumpAndSettle();
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final morningTitle = (find.byType(ListTile).first.evaluate().single.widget as ListTile).title;
      final afternoonTitle = (find.byType(ListTile).last.evaluate().single.widget as ListTile).title;
      final morningDx = tester.getBottomLeft(find.byWidget(morningTitle!)).dx;
      final afternoonDx = tester.getBottomLeft(find.byWidget(afternoonTitle!)).dx;
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
        whenListen(
          diaryBloc,
          Stream.value(DiaryLoaded(BuiltList<DiaryEntry>([mealEntry]))),
          initialState: DiaryLoading(),
        );
      });

      testWidgets('shows tile', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();
        await scrollToTop(tester);
        await tester.pumpAndSettle();
        expect(find.text('Mon, Mar 4'), findsOneWidget);
        expect(find.text('11:23 AM'), findsOneWidget);
        expect(find.text('Meal/Snack'), findsOneWidget);
      });

      testWidgets('tile routes to page', (WidgetTester tester) async {
        final navigationKey = UniqueKey();

        when(() => routes.createMealEntryRoute(entry: any(named: 'entry')))
            .thenReturn(MockPageRoute(key: navigationKey));

        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();
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
        whenListen(
          diaryBloc,
          Stream.value(DiaryLoaded(BuiltList<DiaryEntry>([bowelMovementEntry]))),
          initialState: DiaryLoading(),
        );
      });

      testWidgets('shows bowel movement entry', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();
        await scrollToTop(tester);
        await tester.pumpAndSettle();
        expect(find.text('Mon, Mar 4'), findsOneWidget);
        expect(find.text('11:23 AM'), findsOneWidget);
        expect(find.text('Bowel Movement'), findsOneWidget);
      });

      testWidgets('tile routes to page', (WidgetTester tester) async {
        final navigationKey = UniqueKey();

        when(() => routes.createBowelMovementEntryRoute(entry: any(named: 'entry')))
            .thenReturn(MockPageRoute(key: navigationKey));

        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();
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
        whenListen(
          diaryBloc,
          Stream.value(DiaryLoaded(BuiltList<DiaryEntry>([symptomEntry]))),
          initialState: DiaryLoading(),
        );
      });

      testWidgets('shows symptom entry', (WidgetTester tester) async {
        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();
        await scrollToTop(tester);
        await tester.pumpAndSettle();
        expect(find.text('Mon, Mar 4'), findsOneWidget);
        expect(find.text('11:23 AM'), findsOneWidget);
        expect(find.text(symptomName), findsOneWidget);
      });

      testWidgets('tile routes to page', (WidgetTester tester) async {
        final navigationKey = UniqueKey();

        when(() => routes.createSymptomEntryRoute(entry: any(named: 'entry')))
            .thenReturn(MockPageRoute(key: navigationKey));

        await tester.pumpWidget(diaryPage);
        await tester.pumpAndSettle();
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
        whenListen(
          diaryBloc,
          Stream.value(DiaryLoaded(BuiltList<DiaryEntry>([]))),
          initialState: DiaryLoading(),
        );
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

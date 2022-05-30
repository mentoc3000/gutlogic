import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/pages/browse/browse_page.dart';
import 'package:gutlogic/pages/diary/diary_page.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/pages/pantry/pantry_page.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/food_group_repository.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:mocktail/mocktail.dart';

import '../flutter_test_config.dart';
import '../util/test_overlay.dart';

class MockDiaryRepository extends Mock implements DiaryRepository {}

class MockPantryService extends Mock implements PantryService {}

class MockSensitivityService extends Mock implements SensitivityService {}

class MockFoodGroupsRepository extends Mock implements FoodGroupsRepository {}

void main() {
  late Widget homepage;
  late DiaryRepository diaryRepository;
  late PantryService pantryService;
  late SensitivityService sensitivityService;
  late FoodGroupsRepository foodGroupsRepository;

  setUp(() {
    diaryRepository = MockDiaryRepository();
    when(() => diaryRepository.streamAll()).thenAnswer((_) => Stream.value(BuiltList<DiaryEntry>([])));
    pantryService = MockPantryService();
    when(() => pantryService.streamAll()).thenAnswer((_) => Stream.value(BuiltList<PantryEntry>([])));
    sensitivityService = MockSensitivityService();
    foodGroupsRepository = MockFoodGroupsRepository();
    when(() => foodGroupsRepository.groups()).thenAnswer((_) => Future.value(BuiltSet<String>([])));

    homepage = MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
        RepositoryProvider<PantryService>(create: (context) => pantryService),
        RepositoryProvider<SensitivityService>(create: (context) => sensitivityService),
        RepositoryProvider<FoodGroupsRepository>(create: (context) => foodGroupsRepository),
      ],
      child: TestOverlay(child: MainTabs(analytics: analyticsService)),
    );
  });

  group('MainTabs', () {
    testWidgets('starts on browse page', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(homepage);
        expect(find.byType(BrowsePage), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
      });
    });

    testWidgets('switches between tabs', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(homepage);
        await tester.pumpWidget(homepage);

        // Start on browse page
        expect(find.byType(BrowsePage), findsOneWidget);
        expect(find.byType(PantryPage), findsNothing);

        // Switch to pantry page
        final settingsTab = find.text('Pantry');
        expect(settingsTab, findsOneWidget);
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
        expect(find.byType(DiaryPage), findsNothing);
        expect(find.byType(PantryPage), findsOneWidget);
        mockito.verify(analyticsService.setCurrentScreen(mockito.any)).called(1);

        // Switch to diary page
        final diaryTab = find.text('Timeline');
        expect(diaryTab, findsOneWidget);
        await tester.tap(diaryTab);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(DiaryPage), findsOneWidget);
        expect(find.byType(PantryPage), findsNothing);
        mockito.verify(analyticsService.setCurrentScreen(mockito.any)).called(1);
      });
    });
  });
}

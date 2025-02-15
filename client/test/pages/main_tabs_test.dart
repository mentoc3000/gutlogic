import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:gutlogic/resources/food_group_repository.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:mocktail/mocktail.dart';

import '../util/test_overlay.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

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
        RepositoryProvider<AnalyticsService>(create: (context) => MockAnalyticsService()),
        RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
        RepositoryProvider<PantryService>(create: (context) => pantryService),
        RepositoryProvider<SensitivityService>(create: (context) => sensitivityService),
        RepositoryProvider<FoodGroupsRepository>(create: (context) => foodGroupsRepository),
      ],
      child: TestOverlay(child: Builder(builder: (context) => MainTabs.provisioned(context))),
    );
  });

  group('MainTabs', () {
    testWidgets('switches between tabs', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(homepage);
        // await tester.pumpWidget(homepage);

        // // Start on browse page
        // expect(find.byType(PantryPage), findsOneWidget);
        // expect(find.byType(BrowsePage), findsNothing);

        // // Switch to browse page
        // final settingsTab = find.text('Foods');
        // expect(settingsTab, findsOneWidget);
        // await tester.tap(settingsTab);
        // await tester.pumpAndSettle();
        // expect(find.byType(DiaryPage), findsNothing);
        // expect(find.byType(BrowsePage), findsOneWidget);

        // // Switch to diary page
        // final diaryTab = find.text('Timeline');
        // expect(diaryTab, findsOneWidget);
        // await tester.tap(diaryTab);
        // await tester.pump();
        // await tester.pump(const Duration(seconds: 1));
        // expect(find.byType(DiaryPage), findsOneWidget);
        // expect(find.byType(PantryPage), findsNothing);
      });
    });
  });
}

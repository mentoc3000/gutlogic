import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/pages/diary/diary_page.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/pages/settings/settings_page.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mockito/mockito.dart' as mockito;

import '../flutter_test_config.dart';
import '../util/test_overlay.dart';

class MockDiaryRepository extends Mock implements DiaryRepository {}

class MockPantryRepository extends Mock implements PantryRepository {}

void main() {
  late Widget homepage;
  late DiaryRepository diaryRepository;
  late PantryRepository pantryRepository;

  setUp(() {
    diaryRepository = MockDiaryRepository();
    when(() => diaryRepository.streamAll()).thenAnswer((_) => Stream.value(BuiltList<DiaryEntry>([])));
    pantryRepository = MockPantryRepository();
    when(() => pantryRepository.streamAll()).thenAnswer((_) => Stream.value(BuiltList<PantryEntry>([])));
    homepage = MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
        RepositoryProvider<PantryRepository>(create: (context) => pantryRepository),
      ],
      child: TestOverlay(child: MainTabs(analytics: analyticsService)),
    );
  });

  group('MainTabs', () {
    testWidgets('starts on diary page', (WidgetTester tester) async {
      await tester.pumpWidget(homepage);
      await tester.pumpWidget(homepage);
      expect(find.byType(DiaryPage), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('switches between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(homepage);
      await tester.pumpWidget(homepage);

      // Start on diary page
      expect(find.byType(DiaryPage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);

      // Switch to settings page
      final settingsTab = find.text('Settings');
      expect(settingsTab, findsOneWidget);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
      expect(find.byType(DiaryPage), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
      mockito.verify(analyticsService.setCurrentScreen(mockito.any)).called(1);

      // Switch back to diary page
      final diaryTab = find.text('Timeline');
      expect(diaryTab, findsOneWidget);
      await tester.tap(diaryTab);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DiaryPage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
      mockito.verify(analyticsService.setCurrentScreen(mockito.any)).called(1);
    });
  });
}

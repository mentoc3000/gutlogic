import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/pages/diary/diary_page.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/pages/settings/settings_page.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_analytics_service.dart';

class MockDiaryRepository extends Mock implements DiaryRepository {}

class MainTabsPageWrapper extends StatelessWidget {
  final AnalyticsService analyticsService;

  const MainTabsPageWrapper({this.analyticsService});

  @override
  Widget build(BuildContext context) => MaterialApp(home: MainTabs(analyticsService: analyticsService));
}

void main() {
  Widget homepage;
  AnalyticsService analyticsService;

  setUp(() {
    analyticsService = MockAnalyticsService();
    homepage = RepositoryProvider<DiaryRepository>(
      create: (context) => MockDiaryRepository(),
      child: MainTabsPageWrapper(analyticsService: analyticsService),
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
      verify(analyticsService.setCurrentScreen(any)).called(1);

      // Switch back to diary page
      final diaryTab = find.text('Timeline');
      expect(diaryTab, findsOneWidget);
      await tester.tap(diaryTab);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DiaryPage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
      verify(analyticsService.setCurrentScreen(any)).called(1);
    });
  });
}

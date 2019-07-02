import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:gut_ai/pages/diary_page.dart';
import 'package:gut_ai/blocs/diary_entry_bloc.dart';
import 'package:gut_ai/blocs/database_state.dart';

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
      await tester.pump(Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/bowel_movement_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/pages/bowel_movement_entry/bowel_movement_entry_page.dart';
import 'package:gutlogic/pages/bowel_movement_entry/widgets/bm_type_card.dart';
import 'package:gutlogic/pages/bowel_movement_entry/widgets/bm_volume_card.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:mocktail/mocktail.dart';

class MockBowelMovementEntryBloc extends MockBloc<BowelMovementEntryEvent, BowelMovementEntryState>
    implements BowelMovementEntryBloc {}

void main() {
  late BowelMovementEntryBloc bowelmovementEntryBloc;
  late Widget bowelmovementEntryPage;
  late BowelMovementEntry bowelmovementEntry;

  setUp(() {
    bowelmovementEntryBloc = MockBowelMovementEntryBloc();

    bowelmovementEntry = BowelMovementEntry(
      id: 'bowelmovement1',
      datetime: DateTime(2019, 3, 4, 11, 23),
      bowelMovement: BowelMovement(type: 3, volume: 5),
      notes: 'notes',
    );

    bowelmovementEntryPage = MaterialApp(
      home: BlocProvider.value(
        value: bowelmovementEntryBloc,
        child: BowelMovementEntryPage(),
      ),
    );
  });

  tearDown(() {
    bowelmovementEntryBloc.close();
  });

  group('BowelMovementEntryPage', () {
    testWidgets('loads entry', (WidgetTester tester) async {
      whenListen(
        bowelmovementEntryBloc,
        Stream.fromIterable([BowelMovementEntryLoaded(bowelmovementEntry)]),
        initialState: BowelMovementEntryLoading(),
      );
      await tester.pumpWidget(bowelmovementEntryPage);
      await tester.pumpAndSettle();
      expect(find.text('Bowel Movement'), findsOneWidget);
      expect(find.text(bowelmovementEntry.notes!), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      verifyNever(() => bowelmovementEntryBloc.add(any()));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      whenListen(
        bowelmovementEntryBloc,
        Stream.fromIterable([BowelMovementEntryLoading()]),
        initialState: BowelMovementEntryLoading(),
      );

      await tester.pumpWidget(bowelmovementEntryPage);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Bowel Movement'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(() => bowelmovementEntryBloc.add(any()));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(
        bowelmovementEntryBloc,
        Stream.fromIterable([BowelMovementEntryError(message: message)]),
        initialState: BowelMovementEntryLoading(),
      );

      await tester.pumpWidget(bowelmovementEntryPage);
      await tester.pumpAndSettle();
      expect(find.text('Bowel Movement'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      verifyNever(() => bowelmovementEntryBloc.add(any()));
    });

    testWidgets('updates volume', (WidgetTester tester) async {
      whenListen(
        bowelmovementEntryBloc,
        Stream.fromIterable([BowelMovementEntryLoaded(bowelmovementEntry)]),
        initialState: BowelMovementEntryLoading(),
      );

      await tester.pumpWidget(bowelmovementEntryPage);
      await tester.pumpAndSettle();
      final volumeSlider = find.descendant(of: find.byType(BMVolumeCard), matching: find.byType(Slider));
      expect(volumeSlider, findsOneWidget);
      await tester.tap(volumeSlider);
      verify(() => bowelmovementEntryBloc.add(const UpdateVolume(3))).called(1);
    });

    testWidgets('updates type', (WidgetTester tester) async {
      whenListen(
        bowelmovementEntryBloc,
        Stream.fromIterable([BowelMovementEntryLoaded(bowelmovementEntry)]),
        initialState: BowelMovementEntryLoading(),
      );

      await tester.pumpWidget(bowelmovementEntryPage);
      await tester.pumpAndSettle();
      final typeSlider = find.descendant(of: find.byType(BMTypeCard), matching: find.byType(Slider));
      expect(typeSlider, findsOneWidget);
      await tester.tap(typeSlider);
      verify(() => bowelmovementEntryBloc.add(const UpdateType(4))).called(1);
    });

    testWidgets('updates notes', (WidgetTester tester) async {
      whenListen(
        bowelmovementEntryBloc,
        Stream.fromIterable([BowelMovementEntryLoaded(bowelmovementEntry)]),
        initialState: BowelMovementEntryLoading(),
      );

      await tester.pumpWidget(bowelmovementEntryPage);
      await tester.pumpAndSettle();
      final notesField = find.text(bowelmovementEntry.notes!);
      expect(notesField, findsOneWidget);
      const newNote = 'new notes';
      await tester.enterText(notesField, newNote);
      expect(find.text(bowelmovementEntry.notes!), findsNothing);
      expect(find.text(newNote), findsOneWidget);
      verify(() => bowelmovementEntryBloc.add(const UpdateBowelMovementEntryNotes(newNote))).called(1);
    });
  });
}

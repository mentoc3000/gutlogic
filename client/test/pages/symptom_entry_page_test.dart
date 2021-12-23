import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/symptom_entry/symptom_entry.dart';
import 'package:gutlogic/blocs/symptom_type/symptom_type.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/pages/symptom_entry/symptom_entry_page.dart';
import 'package:gutlogic/pages/symptom_entry/widgets/severity_slider.dart';
import 'package:gutlogic/widgets/gl_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockSymptomEntryBloc extends MockBloc<SymptomEntryEvent, SymptomEntryState> implements SymptomEntryBloc {}

class MockSymptomTypeBloc extends MockBloc<SymptomTypeEvent, SymptomTypeState> implements SymptomTypeBloc {}

void main() {
  late SymptomEntryBloc symptomEntryBloc;
  late SymptomTypeBloc symptomTypeBloc;
  late Widget symptomEntryPage;
  late SymptomEntry symptomEntry;

  setUp(() {
    symptomEntryBloc = MockSymptomEntryBloc();
    symptomTypeBloc = MockSymptomTypeBloc();

    symptomEntry = SymptomEntry(
      id: 'symptom1',
      datetime: DateTime(2019, 3, 4, 11, 23),
      symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: 'Gas'), severity: Severity.mild),
      notes: 'notes',
    );

    symptomEntryPage = MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: symptomEntryBloc),
          BlocProvider.value(value: symptomTypeBloc),
        ],
        child: SymptomEntryPage(),
      ),
    );
  });

  tearDown(() {
    symptomEntryBloc.close();
    symptomTypeBloc.close();
  });

  group('SymptomEntryPage', () {
    testWidgets('loads entry', (WidgetTester tester) async {
      whenListen(
        symptomEntryBloc,
        Stream.fromIterable([
          SymptomEntryLoading(),
          SymptomEntryLoaded(symptomEntry),
        ]),
        initialState: SymptomEntryLoading(),
      );

      await tester.pumpWidget(symptomEntryPage);
      await tester.pumpAndSettle();
      expect(find.text(symptomEntry.symptom.symptomType.name), findsOneWidget);
      expect(find.text(symptomEntry.notes!), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      verifyNever(() => symptomEntryBloc.add(any()));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      await tester.runAsync(() async {
        whenListen(
          symptomEntryBloc,
          Stream.value(SymptomEntryLoading()),
          initialState: SymptomEntryLoading(),
        );

        await tester.pumpWidget(symptomEntryPage);
        expect(find.text('Symptom'), findsOneWidget);
        expect(find.byType(LoadingPage), findsOneWidget);
        verifyNever(() => symptomEntryBloc.add(any()));
      });
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(
        symptomEntryBloc,
        Stream.fromIterable([
          SymptomEntryLoading(),
          SymptomEntryError(message: message),
        ]),
        initialState: SymptomEntryLoading(),
      );

      await tester.pumpWidget(symptomEntryPage);
      await tester.pumpAndSettle();
      expect(find.text('Symptom'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      verifyNever(() => symptomEntryBloc.add(any()));
    });

    testWidgets('updates symptom type', (WidgetTester tester) async {
      whenListen(
        symptomEntryBloc,
        Stream.fromIterable([
          SymptomEntryLoading(),
          SymptomEntryLoaded(symptomEntry),
        ]),
        initialState: SymptomEntryLoading(),
      );

      final newSymptomType = SymptomType(id: 'symptomType1', name: 'Bloat');
      final symptomTypes = [newSymptomType].build();
      whenListen(symptomTypeBloc, Stream.value(SymptomTypesLoaded(symptomTypes)), initialState: SymptomTypesLoading());

      // Show initial symptomEntry
      await tester.pumpWidget(symptomEntryPage);
      await tester.pumpAndSettle();
      expect(find.text(symptomEntry.symptom.symptomType.name), findsOneWidget);

      // Tap search icon
      final searchIcon = find.byIcon(GLIcons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      // Search for anything
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      const search = 'Anything';
      await tester.enterText(searchField, search);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      verify(() => symptomTypeBloc.add(const FetchSymptomTypeQuery(search))).called(1);

      // Select new symptom type
      expect(find.text(newSymptomType.name), findsOneWidget);
      await tester.tap(find.text(newSymptomType.name));
      await tester.pumpAndSettle();
      verify(() => symptomEntryBloc.add(UpdateSymptomType(newSymptomType))).called(1);
    });

    testWidgets('updates severity', (WidgetTester tester) async {
      whenListen(
        symptomEntryBloc,
        Stream.fromIterable([
          SymptomEntryLoading(),
          SymptomEntryLoaded(symptomEntry),
        ]),
        initialState: SymptomEntryLoading(),
      );

      await tester.pumpWidget(symptomEntryPage);
      await tester.pumpAndSettle();
      final severitySlider = find.byType(SeveritySlider);
      expect(severitySlider, findsOneWidget);
      final moderateLabel = find.text('Moderate');
      await tester.tap(moderateLabel);
      await tester.pumpAndSettle();
      verify(() => symptomEntryBloc.add(const UpdateSeverity(Severity.moderate))).called(1);
    });

    testWidgets('updates notes', (WidgetTester tester) async {
      whenListen(
        symptomEntryBloc,
        Stream.fromIterable([
          SymptomEntryLoading(),
          SymptomEntryLoaded(symptomEntry),
        ]),
        initialState: SymptomEntryLoading(),
      );

      await tester.pumpWidget(symptomEntryPage);
      await tester.pumpAndSettle();
      final notesField = find.text(symptomEntry.notes!);
      expect(notesField, findsOneWidget);
      const newNote = 'new notes';
      await tester.enterText(notesField, newNote);
      expect(find.text(symptomEntry.notes!), findsNothing);
      expect(find.text(newNote), findsOneWidget);
      verify(() => symptomEntryBloc.add(const UpdateSymptomEntryNotes(newNote))).called(1);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/symptom_type/symptom_type.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/pages/search_delegate/symptom_type_search_delegate.dart';
import 'package:gutlogic/widgets/gl_app_bar.dart';
import 'package:gutlogic/widgets/gl_icons.dart';
import 'package:gutlogic/widgets/gl_scaffold.dart';
import 'package:mockito/mockito.dart';

class MockSymptomTypeBloc extends MockBloc<SymptomTypeEvent, SymptomTypeState> implements SymptomTypeBloc {}

void main() {
  SymptomTypeBloc symptomTypeBloc;
  SymptomType symptomType;

  setUp(() {
    symptomTypeBloc = MockSymptomTypeBloc();
    symptomType = SymptomType(id: 'symptomType1', name: 'Pain');
  });

  tearDown(() {
    symptomTypeBloc.close();
  });

  group('SymptomTypeSearchDelegate', () {
    testWidgets('opens and closes search', (WidgetTester tester) async {
      final delegate = SymptomTypeSearchDelegate(symptomTypeBloc: symptomTypeBloc);
      final selectedResults = <SymptomType>[];

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<SymptomTypeBloc>.value(value: symptomTypeBloc)],
        child: TestHomePage(
          delegate: delegate,
          results: selectedResults,
        ),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // We are on the homepage
      expect(find.text('HomeBody'), findsOneWidget);
      expect(find.text('HomeTitle'), findsOneWidget);

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();

      expect(find.text('HomeBody'), findsNothing);
      expect(find.text('HomeTitle'), findsNothing);
      expect(selectedResults, hasLength(0));

      // Close search
      await tester.tap(find.byIcon(GLIcons.arrowBack));
      await tester.pumpAndSettle();

      expect(find.text('HomeBody'), findsOneWidget);
      expect(find.text('HomeTitle'), findsOneWidget);
    });

    testWidgets('shows all results when query is blank', (WidgetTester tester) async {
      when(symptomTypeBloc.state).thenReturn(SymptomTypesLoaded(BuiltList.from([symptomType])));
      final delegate = SymptomTypeSearchDelegate(symptomTypeBloc: symptomTypeBloc);

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<SymptomTypeBloc>.value(value: symptomTypeBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();
      expect(find.text(symptomType.name), findsOneWidget);
    });

    testWidgets('shows search results', (WidgetTester tester) async {
      when(symptomTypeBloc.state).thenReturn(SymptomTypesLoaded(BuiltList.from([symptomType])));
      final delegate = SymptomTypeSearchDelegate(symptomTypeBloc: symptomTypeBloc);

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<SymptomTypeBloc>.value(value: symptomTypeBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // We are on the homepage
      expect(find.text('HomeBody'), findsOneWidget);
      expect(find.text('HomeTitle'), findsOneWidget);

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();

      // Shows results as user types
      await tester.enterText(find.byType(TextField), 'Pai');
      await tester.pumpAndSettle();
      expect(find.text(symptomType.name), findsOneWidget);

      // Shows search results
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('HomeBody'), findsNothing);
      expect(find.text('HomeTitle'), findsNothing);
      expect(find.text(symptomType.name), findsOneWidget);
    });

    testWidgets('clears search', (WidgetTester tester) async {
      when(symptomTypeBloc.state).thenReturn(SymptomTypesLoaded(BuiltList.from([symptomType])));
      final delegate = SymptomTypeSearchDelegate(symptomTypeBloc: symptomTypeBloc);

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<SymptomTypeBloc>.value(value: symptomTypeBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // We are on the homepage
      expect(find.text('HomeBody'), findsOneWidget);
      expect(find.text('HomeTitle'), findsOneWidget);

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Pai');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Clear search, show all
      await tester.tap(find.byIcon(GLIcons.clear));
      await tester.pumpAndSettle();
      expect(find.text('Pai'), findsNothing);
      expect(find.text(symptomType.name), findsOneWidget);
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      when(symptomTypeBloc.state).thenReturn(SymptomTypeError(message: message));
      final delegate = SymptomTypeSearchDelegate(symptomTypeBloc: symptomTypeBloc);

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<SymptomTypeBloc>.value(value: symptomTypeBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Pain');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
    });
  });
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({
    Key key,
    this.results,
    this.delegate,
    this.passInInitialQuery = false,
    this.initialQuery,
  }) : super(key: key);

  final List<SymptomType> results;
  final SymptomTypeSearchDelegate delegate;
  final bool passInInitialQuery;
  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (BuildContext context) {
        return GLScaffold(
          appBar: GLAppBar(
            title: 'HomeTitle',
            actions: <Widget>[
              IconButton(
                tooltip: 'Search',
                icon: const Icon(GLIcons.search),
                onPressed: () async {
                  SymptomType selectedResult;
                  if (passInInitialQuery) {
                    selectedResult = await showSearch<SymptomType>(
                      context: context,
                      delegate: delegate,
                      query: initialQuery,
                    );
                  } else {
                    selectedResult = await showSearch<SymptomType>(
                      context: context,
                      delegate: delegate,
                    );
                  }
                  results?.add(selectedResult);
                },
              ),
            ],
          ),
          body: const Text('HomeBody'),
        );
      }),
    );
  }
}

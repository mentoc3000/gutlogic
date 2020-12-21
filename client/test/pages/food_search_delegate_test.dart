import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/food/food.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food/food.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/pages/search_delegate/food_search_delegate.dart';
import 'package:gutlogic/widgets/gl_app_bar.dart';
import 'package:gutlogic/widgets/gl_icons.dart';
import 'package:gutlogic/widgets/gl_scaffold.dart';
import 'package:mockito/mockito.dart';

class MockFoodBloc extends MockBloc<FoodEvent, FoodState> implements FoodBloc {}

void main() {
  FoodBloc foodBloc;
  Food food;

  setUp(() {
    foodBloc = MockFoodBloc();
    food = CustomFood(id: '1', name: 'Fruit Cake');
  });

  tearDown(() {
    foodBloc.close();
  });

  group('FoodSearchDelegate', () {
    testWidgets('opens and closes search', (WidgetTester tester) async {
      final delegate = FoodSearchDelegate(foodBloc: foodBloc, onSelect: (_) {});
      final selectedResults = <Food>[];

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<FoodBloc>.value(value: foodBloc)],
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

    testWidgets('displays message when no results are found', (WidgetTester tester) async {
      when(foodBloc.state)
          .thenReturn(FoodsLoaded(customFoods: <CustomFood>[].build(), edamamFoods: <EdamamFood>[].build()));
      final delegate = FoodSearchDelegate(foodBloc: foodBloc, onSelect: (_) {});

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<FoodBloc>.value(value: foodBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Fruit');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('No matches found. Try adding a food!'), findsOneWidget);
    });

    testWidgets('shows search results', (WidgetTester tester) async {
      when(foodBloc.state)
          .thenReturn(FoodsLoaded(customFoods: <CustomFood>[food].build(), edamamFoods: <EdamamFood>[].build()));

      final delegate = FoodSearchDelegate(foodBloc: foodBloc, onSelect: (_) {});

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<FoodBloc>.value(value: foodBloc)],
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

      // Shows suggestions
      await tester.enterText(find.byType(TextField), 'Fruit');
      await tester.pumpAndSettle();
      expect(find.text(food.name), findsOneWidget);

      // Shows search results
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('HomeBody'), findsNothing);
      expect(find.text('HomeTitle'), findsNothing);
      expect(find.text(food.name), findsOneWidget);
    });

    testWidgets('clears search', (WidgetTester tester) async {
      when(foodBloc.state)
          .thenReturn(FoodsLoaded(customFoods: <CustomFood>[food].build(), edamamFoods: <EdamamFood>[].build()));
      final delegate = FoodSearchDelegate(foodBloc: foodBloc, onSelect: (_) {});

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<FoodBloc>.value(value: foodBloc)],
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
      await tester.enterText(find.byType(TextField), 'Fruit');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Clear search
      await tester.tap(find.byIcon(GLIcons.clear));
      await tester.pumpAndSettle();
      expect(find.text('Fruit'), findsNothing);
      expect(find.text(food.name), findsNothing);
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      when(foodBloc.state).thenReturn(FoodsLoading());
      final delegate = FoodSearchDelegate(foodBloc: foodBloc, onSelect: (_) {});

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<FoodBloc>.value(value: foodBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pump();
      await tester.pump();
      expect(find.byType(LoadingPage), findsOneWidget);
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      when(foodBloc.state).thenReturn(FoodError(message: message));
      final delegate = FoodSearchDelegate(foodBloc: foodBloc, onSelect: (_) {});

      final homepage = MultiBlocProvider(
        providers: [BlocProvider<FoodBloc>.value(value: foodBloc)],
        child: TestHomePage(delegate: delegate),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Fruit');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
    });
  }, skip: true);
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({
    Key key,
    this.results,
    this.delegate,
    this.passInInitialQuery = false,
    this.initialQuery,
  }) : super(key: key);

  final List<Food> results;
  final FoodSearchDelegate delegate;
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
                  Food selectedResult;
                  if (passInInitialQuery) {
                    selectedResult = await showSearch<Food>(
                      context: context,
                      delegate: delegate,
                      query: initialQuery,
                    );
                  } else {
                    selectedResult = await showSearch<Food>(
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

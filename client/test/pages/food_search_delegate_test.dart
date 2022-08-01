import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/food_search/food_search.dart';
import 'package:gutlogic/blocs/foods_suggestion/foods_suggestion.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/food_reference/food_reference.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/pages/search_delegate/food_search_delegate.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:gutlogic/widgets/gl_app_bar.dart';
import 'package:gutlogic/widgets/gl_icons.dart';
import 'package:gutlogic/widgets/gl_scaffold.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFoodBloc extends MockBloc<FoodSearchEvent, FoodSearchState> implements FoodSearchBloc {}

class MockRecentFoodsCubit extends MockCubit<FoodsSuggestionState> implements FoodGroupCubit {}

class MockSensitivityService extends Mock implements SensitivityService {}

void main() {
  late FoodSearchBloc foodBloc;
  late SensitivityService sensitivityService;
  late FoodGroupCubit recentFoodsCubit;
  late CustomFood food;
  late CustomFoodReference recentFoodReference;

  setUp(() {
    foodBloc = MockFoodBloc();
    whenListen(foodBloc, const Stream<FoodSearchState>.empty(), initialState: FoodSearchLoading());
    food = CustomFood(id: '1', name: 'Fruit Cake');

    sensitivityService = MockSensitivityService();
    when(() => sensitivityService.of(any())).thenAnswer((_) => Future.value(Sensitivity.unknown));

    recentFoodReference = CustomFoodReference(id: '2', name: 'Figgy Pudding');
    recentFoodsCubit = MockRecentFoodsCubit();
    whenListen(
      recentFoodsCubit,
      Stream.value(FoodsSuggestionLoaded([recentFoodReference].toBuiltList())),
      initialState: const FoodsSuggestionLoading(),
    );
  });

  tearDown(() {
    foodBloc.close();
    recentFoodsCubit.close();
  });

  group('FoodSearchDelegate', () {
    testWidgets('opens and closes search', (WidgetTester tester) async {
      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );
      final selectedResults = <FoodReference>[];

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(
            delegate: delegate,
            results: selectedResults,
          ),
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
      whenListen(foodBloc, Stream.value(NoFoodsFound(query: '')), initialState: FoodSearchLoading());
      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(delegate: delegate),
        ),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Fruit');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(delegate.noResultsMessage), findsOneWidget);
    });

    testWidgets('shows suggestions', (WidgetTester tester) async {
      whenListen(
        foodBloc,
        Stream.value(FoodSearchLoaded(query: '', items: [food].build())),
        initialState: FoodSearchLoading(),
      );

      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(delegate: delegate),
        ),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pumpAndSettle();

      // Shows recent foods
      expect(find.text(food.name), findsNothing);
      expect(find.text(recentFoodReference.name), findsOneWidget);
    });

    testWidgets('shows search results', (WidgetTester tester) async {
      whenListen(
        foodBloc,
        Stream.value(FoodSearchLoaded(query: '', items: [food].build())),
        initialState: FoodSearchLoading(),
      );

      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(delegate: delegate),
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

      // Shows recent foods
      expect(find.text(food.name), findsNothing);
      expect(find.text(recentFoodReference.name), findsOneWidget);

      // Shows search results
      await tester.enterText(find.byType(TextField), 'Fruit');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('HomeBody'), findsNothing);
      expect(find.text('HomeTitle'), findsNothing);
      expect(find.text(food.name), findsOneWidget);
    });

    testWidgets('clears search', (WidgetTester tester) async {
      whenListen(
        foodBloc,
        Stream.value(FoodSearchLoaded(query: '', items: [food].build())),
        initialState: FoodSearchLoading(),
      );
      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(delegate: delegate),
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
      whenListen(foodBloc, Stream.fromIterable([FoodSearchLoading()]));
      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(delegate: delegate),
        ),
      );

      await tester.pumpWidget(homepage);
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(GLIcons.search));
      await tester.pump();
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Fruit');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump();
      expect(find.byType(LoadingPage), findsOneWidget);
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(foodBloc, Stream.value(FoodSearchError(message: message)), initialState: FoodSearchLoading());
      final delegate = FoodSearchDelegate(
        foodBloc: foodBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (_) {},
      );

      final homepage = MultiBlocProvider(
        providers: [
          BlocProvider<FoodSearchBloc>.value(value: foodBloc),
          BlocProvider<FoodGroupCubit>.value(value: recentFoodsCubit),
        ],
        child: ChangeNotifierProvider(
          create: (context) => sensitivityService,
          child: TestHomePage(delegate: delegate),
        ),
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
  });
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({
    Key? key,
    this.results,
    required this.delegate,
    this.passInInitialQuery = false,
    this.initialQuery,
  }) : super(key: key);

  final List<FoodReference>? results;
  final FoodSearchDelegate delegate;
  final bool passInInitialQuery;
  final String? initialQuery;

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
                  FoodReference? selectedResult;
                  if (passInInitialQuery) {
                    selectedResult = await showSearch<FoodReference?>(
                      context: context,
                      delegate: delegate,
                      query: initialQuery,
                    );
                  } else {
                    selectedResult = await showSearch<FoodReference?>(
                      context: context,
                      delegate: delegate,
                    );
                  }
                  if (selectedResult != null) {
                    results?.add(selectedResult);
                  }
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

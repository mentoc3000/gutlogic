import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/food_search/food_search.dart';
import 'package:gutlogic/blocs/meal_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/pages/meal_entry/meal_entry_page.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:gutlogic/routes/routes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_page_route.dart';
import '../mocks/mock_router.dart';

class MockMealEntryBloc extends MockBloc<MealEntryEvent, MealEntryState> implements MealEntryBloc {}

class MockFoodBloc extends MockBloc<FoodSearchEvent, FoodSearchState> implements FoodSearchBloc {}

class MockSensitivityService extends Mock implements SensitivityService {}

class MealEntryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MealEntryPage());
}

void main() {
  late MealEntryBloc mealEntryBloc;
  late FoodSearchBloc foodBloc;
  late SensitivityService sensitivityService;
  late Routes routes;
  late Widget mealEntryPage;
  late MealEntry mealEntry;

  setUp(() {
    routes = MockRoutes();
    mealEntryBloc = MockMealEntryBloc();
    foodBloc = MockFoodBloc();

    final mealElement = MealElement(
      id: 'meal1#mealElement1',
      foodReference: CustomFoodReference(id: 'food1', name: 'Fruit Cake'),
      quantity: Quantity.unweighed(amount: 3, unit: 'head'),
    );

    mealEntry = MealEntry(
      id: 'meal1',
      datetime: DateTime(2019, 3, 4, 11, 23),
      mealElements: BuiltList<MealElement>([mealElement]),
      notes: 'notes',
    );

    sensitivityService = MockSensitivityService();
    when(() => sensitivityService.of(any())).thenAnswer((_) async => Sensitivity.unknown);

    mealEntryPage = Provider<Routes>.value(
      value: routes,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mealEntryBloc),
          BlocProvider.value(value: foodBloc),
        ],
        child: ChangeNotifierProvider.value(
          value: sensitivityService,
          child: MealEntryPageWrapper(),
        ),
      ),
    );
  });

  tearDown(() {
    mealEntryBloc.close();
    foodBloc.close();
  });

  group('MealEntryPage', () {
    testWidgets('loads entry', (WidgetTester tester) async {
      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          MealEntryLoading(),
          MealEntryLoaded(mealEntry),
        ]),
        initialState: MealEntryLoading(),
      );

      await tester.pumpWidget(mealEntryPage);
      await tester.pumpAndSettle();
      expect(find.text('Meal/Snack'), findsOneWidget);
      // expect(find.text('Monday, March 4, 2019 at 11:23AM'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text(mealEntry.mealElements.first.foodReference.name), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text(mealEntry.notes!), findsOneWidget);
      verifyNever(() => mealEntryBloc.add(any()));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          null, // bloc_test skips first state. https://github.com/felangel/bloc/issues/796
          MealEntryLoading(),
        ]),
        initialState: MealEntryLoading(),
      );

      whenListen(mealEntryBloc, Stream.value(MealEntryLoading()), initialState: MealEntryLoading());
      await tester.pumpWidget(mealEntryPage);
      expect(find.text('Meal/Snack'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(() => mealEntryBloc.add(any()));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          MealEntryLoading(),
          MealEntryError(message: message),
        ]),
        initialState: MealEntryLoading(),
      );

      await tester.pumpWidget(mealEntryPage);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Meal/Snack'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      verifyNever(() => mealEntryBloc.add(any()));
    });

    testWidgets('tile routes to mealElement page', (WidgetTester tester) async {
      final navigationKey = UniqueKey();

      when(() => routes.createMealElementPageRoute(mealElement: any(named: 'mealElement')))
          .thenReturn(MockPageRoute(key: navigationKey));

      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          MealEntryLoading(),
          MealEntryLoaded(mealEntry),
        ]),
        initialState: MealEntryLoading(),
      );

      await tester.pumpWidget(mealEntryPage);
      await tester.pumpAndSettle();

      final tappable = find.text(mealEntry.mealElements.first.foodReference.name);
      await tester.tap(tappable);
      await tester.pumpAndSettle();
      expect(find.byKey(navigationKey), findsOneWidget);
    });

    testWidgets('add button shows food search', (WidgetTester tester) async {
      whenListen(mealEntryBloc, Stream.value(MealEntryLoaded(mealEntry)), initialState: MealEntryLoading());

      final newFood = CustomFood(id: '919', name: 'Hoisin Sauce');
      final foods = [newFood].build();
      whenListen(
        foodBloc,
        Stream.value(FoodSearchLoaded(query: '', items: foods)),
        initialState: FoodSearchLoading(),
      );

      // Show initial mealentry
      await tester.pumpWidget(mealEntryPage);
      await tester.pumpAndSettle();

      // Tap search icon
      final searchButton = find.text('Add Food or Drink');
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Ho');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text(newFood.name), findsOneWidget);
    });

    testWidgets('removes mealElement when dragging mealElement tile left', (WidgetTester tester) async {
      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          MealEntryLoading(),
          MealEntryLoaded(mealEntry),
        ]),
        initialState: MealEntryLoading(),
      );

      await tester.pumpWidget(mealEntryPage);
      await tester.pumpAndSettle();

      // Swipe
      final mealElementTile = find.text(mealEntry.mealElements.first.foodReference.name);
      expect(mealElementTile, findsOneWidget);
      await tester.fling(mealElementTile, const Offset(-500, 0), 1e3);
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(mealElementTile, findsNothing);
      verify(() =>
              mealEntryBloc.add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealEntry.mealElements.first)))
          .called(1);
    });

    testWidgets('does nothing when dragging mealElement tile right', (WidgetTester tester) async {
      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          MealEntryLoading(),
          MealEntryLoaded(mealEntry),
        ]),
        initialState: MealEntryLoading(),
      );

      await tester.pumpWidget(mealEntryPage);
      await tester.pumpAndSettle();

      final mealElementTile = find.text(mealEntry.mealElements.first.foodReference.name);
      expect(mealElementTile, findsOneWidget);
      await tester.drag(mealElementTile, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(mealElementTile, findsOneWidget);
      verifyNever(
          () => mealEntryBloc.add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealEntry.mealElements.first)));
    });

    testWidgets('updates notes', (WidgetTester tester) async {
      whenListen(
        mealEntryBloc,
        Stream.fromIterable([
          MealEntryLoading(),
          MealEntryLoaded(mealEntry),
        ]),
        initialState: MealEntryLoading(),
      );

      await tester.pumpWidget(mealEntryPage);
      await tester.pumpAndSettle();
      final notesField = find.text(mealEntry.notes!);
      expect(notesField, findsOneWidget);
      const newNote = 'new notes';
      await tester.enterText(notesField, newNote);
      expect(find.text(mealEntry.notes!), findsNothing);
      expect(find.text(newNote), findsOneWidget);
      verify(() => mealEntryBloc.add(const UpdateMealEntryNotes(newNote))).called(1);
    });
  });
}

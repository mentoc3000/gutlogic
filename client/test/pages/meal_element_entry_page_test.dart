import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/food/food.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/pages/meal_element_entry/meal_element_entry_page.dart';
import 'package:mockito/mockito.dart';

class MockMealElementBloc extends MockBloc<MealElementState> implements MealElementBloc {}

class MockFoodBloc extends MockBloc<FoodState> implements FoodBloc {}

void main() {
  MealElementBloc mealElementBloc;
  FoodBloc;
  Widget mealElementPage;
  MealElement mealElement;

  setUp(() {
    mealElementBloc = MockMealElementBloc();

    mealElement = MealElement(
      id: 'mealElement1',
      foodReference: CustomFoodReference(id: 'food1', name: 'Fruit Cake'),
      quantity: Quantity.unweighed(amount: 1, unit: 'brick'),
      notes: 'notes',
    );

    mealElementPage = MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mealElementBloc),
        ],
        child: MealElementEntryPage(),
      ),
    );
  });

  tearDown(() {
    mealElementBloc.close();
  });

  group('MealElementPage', () {
    testWidgets('loads entry', (WidgetTester tester) async {
      whenListen(
        mealElementBloc,
        Stream.fromIterable([
          MealElementLoading(),
          MealElementLoaded(mealElement: mealElement),
        ]),
      );

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      expect(find.text(mealElement.foodReference.name), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      verifyNever(mealElementBloc.add(any));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      whenListen(
        mealElementBloc,
        Stream.fromIterable([
          null, // bloc_test skips first state. https://github.com/felangel/bloc/issues/796
          MealElementLoading(),
        ]),
      );

      await tester.pumpWidget(mealElementPage);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Ingredient'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(mealElementBloc.add(any));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(
        mealElementBloc,
        Stream.fromIterable([
          MealElementLoading(),
          MealElementError(message: message),
        ]),
      );

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      expect(find.text('Ingredient'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      verifyNever(mealElementBloc.add(any));
    });

    testWidgets('updates quantity', (WidgetTester tester) async {
      whenListen(
        mealElementBloc,
        Stream.fromIterable([
          MealElementLoading(),
          MealElementLoaded(mealElement: mealElement),
        ]),
      );

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      final amountField = find.text('1.0');
      expect(amountField, findsOneWidget);
      await tester.enterText(amountField, '2.0');
      expect(find.text('1.0'), findsNothing);
      expect(find.text('2.0'), findsOneWidget);
      verify(mealElementBloc
              .add(UpdateQuantity(Quantity.unweighed(amount: 2, unit: mealElement.quantity.measure.unit))))
          .called(1);
    }, skip: true);

    testWidgets('updates notes', (WidgetTester tester) async {
      whenListen(
        mealElementBloc,
        Stream.fromIterable([
          MealElementLoading(),
          MealElementLoaded(mealElement: mealElement),
        ]),
      );

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      final notesField = find.text(mealElement.notes);
      expect(notesField, findsOneWidget);
      const newNote = 'new notes';
      await tester.enterText(notesField, newNote);
      expect(find.text(mealElement.notes), findsNothing);
      expect(find.text(newNote), findsOneWidget);
      verify(mealElementBloc.add(const UpdateNotes(newNote))).called(1);
    });
  });
}

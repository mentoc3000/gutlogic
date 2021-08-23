import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/pages/meal_element_entry/meal_element_entry_page.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockMealElementBloc extends MockBloc<MealElementEvent, MealElementState> implements MealElementBloc {}

class MockSensitivityService extends Mock implements SensitivityService {}

class MealElementPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MealElementEntryPage());
}

void main() {
  late MockMealElementBloc mealElementBloc;
  late SensitivityService sensitivityService;
  late Widget mealElementPage;
  late MealElement mealElement;

  setUp(() {
    mealElementBloc = MockMealElementBloc();

    mealElement = MealElement(
      id: 'mealElement1',
      foodReference: CustomFoodReference(id: 'food1', name: 'Fruit Cake'),
      quantity: Quantity.unweighed(amount: 1, unit: 'brick'),
      notes: 'notes',
    );

    sensitivityService = MockSensitivityService();
    when(() => sensitivityService.of(any())).thenReturn(Sensitivity.unknown);

    mealElementPage = MultiBlocProvider(
      providers: [BlocProvider<MealElementBloc>.value(value: mealElementBloc)],
      child: ChangeNotifierProvider.value(
        value: sensitivityService,
        child: MealElementPageWrapper(),
      ),
    );
  });

  tearDown(() {
    mealElementBloc.close();
  });

  group('MealElementPage', () {
    testWidgets('loads entry', (WidgetTester tester) async {
      whenListen(mealElementBloc, Stream.value(MealElementLoaded(mealElement: mealElement)),
          initialState: MealElementLoading());

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      expect(find.text(mealElement.foodReference.name), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      verifyNever(() => mealElementBloc.add(any()));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      whenListen(mealElementBloc, Stream.value(MealElementLoading()), initialState: MealElementLoading());

      await tester.pumpWidget(mealElementPage);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Ingredient'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(() => mealElementBloc.add(any()));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(mealElementBloc, Stream.value(MealElementError(message: message)), initialState: MealElementLoading());

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      expect(find.text('Ingredient'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      verifyNever(() => mealElementBloc.add(any()));
    });

    testWidgets('updates quantity', (WidgetTester tester) async {
      whenListen(mealElementBloc, Stream.value(MealElementLoaded(mealElement: mealElement)),
          initialState: MealElementLoading());

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      final amountField = find.text('1');
      expect(amountField, findsOneWidget);
      await tester.enterText(amountField, '2.0');
      expect(find.text('1.0'), findsNothing);
      expect(find.text('2.0'), findsOneWidget);
      verify(() => mealElementBloc
          .add(UpdateQuantity(Quantity.unweighed(amount: 2, unit: mealElement.quantity!.measure!.unit)))).called(1);
    });

    testWidgets('updates notes', (WidgetTester tester) async {
      whenListen(mealElementBloc, Stream.value(MealElementLoaded(mealElement: mealElement)),
          initialState: MealElementLoading());

      await tester.pumpWidget(mealElementPage);
      await tester.pumpAndSettle();
      final notesField = find.text(mealElement.notes!);
      expect(notesField, findsOneWidget);
      const newNote = 'new notes';
      await tester.enterText(notesField, newNote);
      expect(find.text(mealElement.notes!), findsNothing);
      expect(find.text(newNote), findsOneWidget);
      verify(() => mealElementBloc.add(const UpdateNotes(newNote))).called(1);
    });
  });
}

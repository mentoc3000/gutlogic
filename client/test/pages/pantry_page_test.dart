import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/blocs/pantry_sort/pantry_sort.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/pantry/pantry_sort.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/pages/pantry/pantry_page.dart';
import 'package:gutlogic/pages/loading_page.dart';
import 'package:gutlogic/routes/routes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';

import '../mocks/mock_page_route.dart';
import '../mocks/mock_router.dart';

class MockPantryBloc extends MockBloc<PantryEvent, PantryState> implements PantryBloc {}

class MockPantrySortCubit extends MockCubit<PantrySortState> implements PantrySortCubit {}

class PantryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: PantryPage());
}

Future<void> scrollToTop(WidgetTester tester) async {
  await tester.dragFrom(const Offset(300, 200), const Offset(0, 1000));
  await tester.pumpAndSettle();
}

void main() {
  late PantryBloc pantryBloc;
  late PantrySortCubit pantrySortCubit;
  late Widget pantryPage;
  late Routes routes;
  const defaultSort = PantrySort.alphabeticalAscending;

  initializeTimeZones();

  setUp(() {
    routes = MockRoutes();
    pantryBloc = MockPantryBloc();
    pantrySortCubit = MockPantrySortCubit();

    whenListen(pantryBloc, Stream.value(PantryLoaded(<PantryEntry>[].build())), initialState: PantryLoading());
    whenListen(pantrySortCubit, Stream.value(PantrySortLoading(sort: defaultSort)),
        initialState: PantrySortLoading(sort: defaultSort));

    pantryPage = Provider<Routes>.value(
      value: routes,
      child: BlocProvider<PantrySortCubit>.value(
        value: pantrySortCubit,
        child: BlocProvider<PantryBloc>.value(
          value: pantryBloc,
          child: PantryPageWrapper(),
        ),
      ),
    );
  });

  group('PantryPage', () {
    testWidgets('shows empty pantry', (WidgetTester tester) async {
      whenListen(pantryBloc, Stream.value(PantryLoaded(<PantryEntry>[].build())), initialState: PantryLoading());
      await tester.pumpWidget(pantryPage);
      expect(find.text('Pantry'), findsOneWidget);
      verifyNever(() => pantryBloc.add(any()));
    });

    testWidgets('shows loading', (WidgetTester tester) async {
      whenListen(pantrySortCubit, Stream.value(PantrySortLoading(sort: defaultSort)),
          initialState: PantrySortLoading(sort: defaultSort));
      await tester.pumpWidget(pantryPage);
      expect(find.text('Pantry'), findsOneWidget);
      expect(find.byType(LoadingPage), findsOneWidget);
      verifyNever(() => pantryBloc.add(any()));
    });

    testWidgets('shows error', (WidgetTester tester) async {
      const message = 'Oh no! Something TERRIBLE happened!';
      whenListen(pantrySortCubit, Stream.value(PantrySortError(message: message, sort: defaultSort)),
          initialState: PantrySortLoading(sort: defaultSort));
      await tester.pumpWidget(pantryPage);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      verifyNever(() => pantryBloc.add(any()));
    });

    testWidgets('removes entry when dragging pantry entry tile left', (WidgetTester tester) async {
      final pantryEntry = PantryEntry(
        id: 'id',
        foodReference: CustomFoodReference(id: 'foodid', name: 'Great Northern Beans'),
        sensitivity: Sensitivity.mild,
      );
      whenListen(
          pantrySortCubit, Stream.value(PantrySortLoaded(items: <PantryEntry>[pantryEntry].build(), sort: defaultSort)),
          initialState: PantrySortLoading(sort: defaultSort));
      await tester.pumpWidget(pantryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final entryTile = find.text('Great Northern Beans');
      expect(entryTile, findsOneWidget);
      await tester.fling(entryTile, const Offset(-500, 0), 1e3);
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(entryTile, findsNothing);
      verify(() => pantryBloc.add(DeletePantryEntry(pantryEntry))).called(1);
    });

    testWidgets('shows an undo snackbar after deleting an entry', (WidgetTester tester) async {
      final pantryEntry = PantryEntry(
        id: 'id',
        foodReference: CustomFoodReference(id: 'foodid', name: 'Great Northern Beans'),
        sensitivity: Sensitivity.mild,
      );
      final entries = [pantryEntry].build();
      whenListen(
        pantryBloc,
        Stream.fromIterable([
          PantryLoaded(entries),
          PantryEntryDeleted(pantryEntry),
        ]),
        initialState: PantryLoading(),
      );
      whenListen(pantrySortCubit, Stream.value(PantrySortLoaded(items: entries, sort: defaultSort)),
          initialState: PantrySortLoading(sort: defaultSort));

      await tester.pumpWidget(pantryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('does nothing when dragging pantry entry tile right', (WidgetTester tester) async {
      final pantryEntry = PantryEntry(
        id: 'id',
        foodReference: CustomFoodReference(id: 'foodid', name: 'Great Northern Beans'),
        sensitivity: Sensitivity.mild,
      );
      whenListen(
          pantrySortCubit, Stream.value(PantrySortLoaded(items: <PantryEntry>[pantryEntry].build(), sort: defaultSort)),
          initialState: PantrySortLoading(sort: defaultSort));
      await tester.pumpWidget(pantryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final entryTile = find.text('Great Northern Beans');
      expect(entryTile, findsOneWidget);
      await tester.drag(entryTile, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(entryTile, findsOneWidget);
      verifyNever(() => pantryBloc.add(DeletePantryEntry(pantryEntry)));
    });

    testWidgets('tile routes to pantry entry page', (WidgetTester tester) async {
      final pantryEntry = PantryEntry(
        id: 'id',
        foodReference: CustomFoodReference(id: 'foodid', name: 'Great Northern Beans'),
        sensitivity: Sensitivity.mild,
      );
      whenListen(
          pantrySortCubit, Stream.value(PantrySortLoaded(items: <PantryEntry>[pantryEntry].build(), sort: defaultSort)),
          initialState: PantrySortLoading(sort: defaultSort));
      await tester.pumpWidget(pantryPage);

      final navigationKey = UniqueKey();
      when(() => routes.createPantryEntryPageRoute(pantryEntry: any(named: 'pantryEntry')))
          .thenReturn(MockPageRoute(key: navigationKey));

      await tester.pumpWidget(pantryPage);
      await scrollToTop(tester);
      await tester.pumpAndSettle();

      final tappable = find.text('Great Northern Beans');
      await tester.tap(tappable);
      await tester.pumpAndSettle();
      expect(find.byKey(navigationKey), findsOneWidget);
    });
  });
}

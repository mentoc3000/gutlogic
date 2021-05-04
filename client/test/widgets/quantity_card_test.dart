import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/pages/meal_element_entry/widgets/quantity_card.dart';
import 'package:gutlogic/pages/meal_element_entry/widgets/unit_dropdown.dart';

import '../util/test_overlay.dart';

void main() {
  group('QuantityCard', () {
    testWidgets('displays initial value', (WidgetTester tester) async {
      const amount = 1.5;
      const unit = 'Bones';
      final quantity = Quantity.unweighed(amount: amount, unit: unit);

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestOverlay(
          child: QuantityCard(
            quantity: quantity,
            unitController: TextEditingController(text: unit),
            amountController: TextEditingController(text: '1.5'),
            onChanged: null,
          ),
        ),
      );

      expect(find.text(amount.toString()), findsOneWidget);
      expect(find.text(unit), findsOneWidget);
    });

    testWidgets('updates amount', (WidgetTester tester) async {
      const initAmount = 1.5;
      const initUnit = 'Bones';
      var quantity = Quantity.unweighed(amount: initAmount, unit: initUnit);

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestOverlay(
          child: QuantityCard(
            quantity: quantity,
            unitController: TextEditingController(text: initUnit),
            amountController: TextEditingController(text: '1.5'),
            onChanged: (newQuantity) => quantity = newQuantity,
          ),
        ),
      );

      const newAmount = 2.0;
      await tester.enterText(find.byType(TextField).first, newAmount.toString());
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text(initAmount.toString()), findsNothing);
      expect(find.text(newAmount.toString()), findsOneWidget);
      expect(quantity.amount, newAmount);
    });

    testWidgets('updates unit with text field', (WidgetTester tester) async {
      const initAmount = 1.5;
      const initUnit = 'Bones';
      var quantity = Quantity.unweighed(amount: initAmount, unit: initUnit);

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestOverlay(
          child: QuantityCard(
            quantity: quantity,
            unitController: TextEditingController(text: initUnit),
            amountController: TextEditingController(text: '1.5'),
            onChanged: (newQuantity) => quantity = newQuantity,
          ),
        ),
      );

      const newUnit = 'Cups';
      expect(find.byType(TextField), findsNWidgets(2));
      await tester.enterText(find.byType(TextField).last, newUnit);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text(initUnit), findsNothing);
      expect(find.text(newUnit), findsOneWidget);
      expect(quantity.measure!.unit, newUnit);
    });

    testWidgets('updates unit with dropdown', (WidgetTester tester) async {
      const initAmount = 1.5;
      final measures = [Measure(unit: 'Cup', weight: 240), Measure(unit: 'Oz', weight: 30)].build();
      final initUnit = measures.first.unit;
      var quantity = Quantity(amount: initAmount, measure: measures.first);

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestOverlay(
          child: QuantityCard(
            quantity: quantity,
            onChanged: (newQuantity) => quantity = newQuantity,
            unitController: TextEditingController(text: initUnit),
            amountController: TextEditingController(text: '1.5'),
            measureOptions: measures,
          ),
        ),
      );

      final newUnit = measures.last.unit;
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(UnitDropdown), findsOneWidget);

      await tester.tap(find.byType(UnitDropdown));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // finish the menu animation
      // We should have two copies of the item, one in the menu and one in the button itself.
      expect(find.text(initUnit), findsNWidgets(2));

      await tester.tap(find.text(newUnit).last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // finish the menu animation

      expect(quantity.measure!.unit, newUnit);
    });

    test('formats amount', () {
      expect(QuantityCard.formatAmount(null), '');
      expect(QuantityCard.formatAmount(0), '0');
      expect(QuantityCard.formatAmount(3), '3');
      expect(QuantityCard.formatAmount(3.0), '3');
      expect(QuantityCard.formatAmount(3.1), '3.10');
      expect(QuantityCard.formatAmount(3.14159), '3.14');
      expect(QuantityCard.formatAmount(3.148), '3.15');
      expect(QuantityCard.formatAmount(1243.148), '1243.15');
    });
  });
}

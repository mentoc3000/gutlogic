import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/widgets/cards/quantity_card.dart';

import '../util/test_overlay.dart';

void main() {
  group('QuantityCard', () {
    // testWidgets('displays default value', (WidgetTester tester) async {
    //   // Build our app and trigger a frame.
    //   await tester.pumpWidget(overlay(child: QuantityView()));

    //   expect(find.text('Amount'), findsOneWidget);
    //   expect(find.text('Units'), findsOneWidget);
    // });

    testWidgets('displays initial value', (WidgetTester tester) async {
      const amount = 1.5;
      const unit = 'Bones';
      final quantity = Quantity.unweighed(amount: amount, unit: unit);

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestOverlay(
          child: QuantityCard(quantity: quantity),
        ),
      );

      expect(find.text(amount.toString()), findsOneWidget);
      expect(find.text(unit), findsOneWidget);
    });

    testWidgets('updates value', (WidgetTester tester) async {
      const initAmount = 1.5;
      const initUnit = 'Bones';
      var quantity = Quantity.unweighed(amount: initAmount, unit: initUnit);

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestOverlay(
          child: QuantityCard(
            quantity: quantity,
            onChanged: (newQuantity) => quantity = newQuantity,
          ),
        ),
      );

      const newAmount = 2.0;
      const newUnit = 'Cups';
      await tester.enterText(find.byType(TextField).first, newAmount.toString());
      await tester.enterText(find.byType(TextField).last, newUnit);

      expect(find.text(initAmount.toString()), findsNothing);
      expect(find.text(initUnit), findsNothing);
      expect(find.text(newAmount.toString()), findsOneWidget);
      expect(find.text(newUnit), findsOneWidget);
      expect(quantity.amount, newAmount);
      expect(quantity.measure.unit, newUnit);
    });
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gut_ai/models/quantity.dart';
import 'package:gut_ai/widgets/quantity_view.dart';

void main() {
  // group('Quantity View widget', () {
  //   testWidgets('displays default value', (WidgetTester tester) async {
  //     // Build our app and trigger a frame.
  //     await tester.pumpWidget(QuantityView());

  //     expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
  //     expect(find.widgetWithText(TextFormField, 'Units'), findsOneWidget);
  //   });
  //   testWidgets('displays initial value', (WidgetTester tester) async {
  //     const double amount = 1.5;
  //     const String unit = 'Bones';
  //     final Quantity quantity = Quantity(amount: amount, unit: unit);

  //     // Build our app and trigger a frame.
  //     await tester.pumpWidget(QuantityView(quantity: quantity));

  //     expect(find.widgetWithText(TextFormField, amount.toString()), findsOneWidget);
  //     expect(find.widgetWithText(TextFormField, unit), findsOneWidget);
  //   });
  // });
}

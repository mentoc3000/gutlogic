import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/pages/meal_element_entry/widgets/amount_text_field.dart';

import '../util/test_overlay.dart';

void main() {
  group('AmountTextField', () {
    late TextEditingController controller;
    late Widget widget;
    double? amount;

    setUp(() {
      controller = TextEditingController();
      widget = TestOverlay(
        child: AmountTextField(
          controller: controller,
          onChanged: (newAmount) {
            amount = newAmount;
          },
        ),
      );
    });

    testWidgets('initializes', (tester) async {
      await tester.pumpWidget(widget);
      expect(controller.text, '');
      expect(amount, null);
    });

    testWidgets('accepts decimal', (tester) async {
      await tester.pumpWidget(widget);
      await tester.enterText(find.byType(TextField).first, '2.73');
      expect(controller.text, '2.73');
      expect(amount, 2.73);
    });

    testWidgets('accepts empty', (tester) async {
      await tester.pumpWidget(widget);
      await tester.enterText(find.byType(TextField).first, '2.73');
      await tester.enterText(find.byType(TextField).first, '');
      expect(controller.text, '');
      expect(amount, null);
    });

    testWidgets('does not accept word', (tester) async {
      await tester.pumpWidget(widget);
      await tester.enterText(find.byType(TextField).first, 'colt');
      expect(controller.text, '');
      expect(amount, null);
    });
  });
}

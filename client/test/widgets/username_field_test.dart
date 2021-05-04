import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/widgets/form_fields/username_field.dart';

import '../util/test_overlay.dart';

void main() {
  group('UsernameField', () {
    late Widget testWidget;

    setUp(() {
      testWidget = TestOverlay(
        child: Form(
          child: Column(
            children: <Widget>[
              UsernameField(controller: TextEditingController()),
              TextFormField(controller: null),
            ],
          ),
        ),
      );
    });

    testWidgets('starts with no validation errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(testWidget);

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Invalid email address.'), findsNothing);
    });

    testWidgets('shows no error with valid email', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      const validEmail = 'jp@gutlogic.co';
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextFormField).first, validEmail);
      await tester.pump();

      expect(find.text(validEmail), findsOneWidget);
      expect(find.text('Invalid email address.'), findsNothing);

      // Change to the second form field to force the focus to change
      await tester.enterText(find.byType(TextFormField).last, 'abc');
      await tester.pump();

      expect(find.text(validEmail), findsOneWidget);
      expect(find.text('Invalid email address.'), findsNothing);
    });

    testWidgets('shows error with invalid email', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      const invalidEmail = 'jp';
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextFormField).first, invalidEmail);
      await tester.pump();

      expect(find.text(invalidEmail), findsOneWidget);
      expect(find.text('Invalid email address.'), findsNothing);

      // Change to the second form field to force the focus to change
      await tester.enterText(find.byType(TextFormField).last, 'abc');
      await tester.pump();

      expect(find.text(invalidEmail), findsOneWidget);
      expect(find.text('Invalid email address.'), findsOneWidget);
    }, skip: true); // TODO update test when new form API lands
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/input/input.dart';
import 'package:gutlogic/util/validators.dart';
import 'package:gutlogic/widgets/form_fields/password_field.dart';

import '../util/test_overlay.dart';

void main() {
  group('PasswordField', () {
    late Widget testWidget;
    const emptyPasswordMessage = 'Enter password.';
    const shortPasswordMessage = 'Password must be at least 10 characters.';
    const longPasswordMessage = 'Password must be fewer than 64 characters.';

    String? validatePassword(String value) {
      if (value.isEmpty) {
        return emptyPasswordMessage;
      }
      if (isPasswordTooShort(value)) {
        return shortPasswordMessage;
      }
      if (isPasswordTooLong(value)) {
        return longPasswordMessage;
      }
      return null;
    }

    final input = InputText(validator: validatePassword);

    setUp(() {
      testWidget = TestOverlay(
        child: Column(
          children: <Widget>[
            PasswordField(input: input),
            TextFormField(),
          ],
        ),
      );
    });

    testWidgets('starts with no validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Password'), findsOneWidget);
      expect(find.text(shortPasswordMessage), findsNothing);
    });

    testWidgets('shows no error with valid password', (WidgetTester tester) async {
      const validPassword = '0123456789';
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextField).first, validPassword);
      await tester.pump();

      expect(find.text(validPassword), findsOneWidget);
      expect(find.text(shortPasswordMessage), findsNothing);
      expect(find.text(longPasswordMessage), findsNothing);

      // Change to the second form field to force the focus to change
      await tester.enterText(find.byType(TextField).last, 'abc');
      await tester.pump();

      expect(find.text(validPassword), findsOneWidget);
      expect(find.text(shortPasswordMessage), findsNothing);
      expect(find.text(longPasswordMessage), findsNothing);
    });

    testWidgets('shows error with empty password', (WidgetTester tester) async {
      const emptyPassword = '';
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextField).first, emptyPassword);
      await tester.pump();

      expect(find.text(emptyPassword), findsNWidgets(2));
      expect(find.text(emptyPasswordMessage), findsNothing);

      // Change to the second form field to force the focus to change
      await tester.enterText(find.byType(TextField).last, 'abc');
      await tester.pump();

      expect(find.text(emptyPassword), findsOneWidget);
      expect(find.text(emptyPasswordMessage), findsOneWidget);
    });

    testWidgets('shows error with short password', (WidgetTester tester) async {
      const shortPassword = 'a';
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextField).first, shortPassword);
      await tester.pump();

      expect(find.text(shortPassword), findsOneWidget);
      expect(find.text(shortPasswordMessage), findsNothing);

      // Change to the second form field to force the focus to change
      await tester.enterText(find.byType(TextField).last, 'abc');
      await tester.pump();

      expect(find.text(shortPassword), findsOneWidget);
      expect(find.text(shortPasswordMessage), findsOneWidget);
    });
  });
}

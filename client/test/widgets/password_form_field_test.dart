import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/widgets/form_fields/password_form_field.dart';

import '../util/test_overlay.dart';

void main() {
  group('PasswordFormField', () {
    Widget testWidget;
    const emptyPasswordMessage = 'Enter password.';
    const shortPasswordMessage = 'Password must be at least 10 characters.';
    const longPasswordMessage = 'Password must be fewer than 64 characters.';

    Widget builder(String Function(String) validator) {
      return TestOverlay(
        child: Form(
          child: Column(
            children: <Widget>[
              PasswordFormField(
                controller: TextEditingController(),
                validator: validator,
              ),
              TextFormField(controller: null),
            ],
          ),
        ),
      );
    }

    group('full validator', () {
      setUp(() {
        testWidget = builder(PasswordValidators.full);
      });

      testWidgets('starts with no validation errors', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(testWidget);

        expect(find.text('Password'), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
      });

      testWidgets('shows no error with valid password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const validPassword = 'kJds;f90sZ.kd"!';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, validPassword);
        await tester.pump();

        expect(find.text(validPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
        expect(find.text(longPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(validPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
        expect(find.text(longPasswordMessage), findsNothing);
      });

      testWidgets('shows error with short password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const shortPassword = 'gutlogi';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, shortPassword);
        await tester.pump();

        expect(find.text(shortPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(shortPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsOneWidget);
      });

      testWidgets('shows error with long password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        final longPassword = 'gutlogicrocksgutlogicrocksgutlogicrocksgutlogicrocks'
                'gutlogicrocksgutlogicrocksgutlogicrocksgutlogicrocks'
            .substring(0, 65);
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, longPassword);
        await tester.pump();

        expect(find.text(longPassword), findsOneWidget);
        expect(find.text(longPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(longPassword), findsOneWidget);
        expect(find.text(longPasswordMessage), findsOneWidget);
      });
    });

    group('length validator', () {
      setUp(() {
        testWidget = builder(PasswordValidators.length);
      });

      testWidgets('starts with no validation errors', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(testWidget);

        expect(find.text('Password'), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
      });

      testWidgets('shows no error with valid password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const validPassword = 'kJds;f90sZ.kd"!';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, validPassword);
        await tester.pump();

        expect(find.text(validPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
        expect(find.text(longPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(validPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
        expect(find.text(longPasswordMessage), findsNothing);
      });

      testWidgets('shows error with short password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const shortPassword = 'gutlogi';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, shortPassword);
        await tester.pump();

        expect(find.text(shortPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(shortPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsOneWidget);
      });

      testWidgets('shows error with long password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        final longPassword = 'gutlogicrocksgutlogicrocksgutlogicrocksgutlogicrocks'
                'gutlogicrocksgutlogicrocksgutlogicrocksgutlogicrocks'
            .substring(0, 65);
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, longPassword);
        await tester.pump();

        expect(find.text(longPassword), findsOneWidget);
        expect(find.text(longPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(longPassword), findsOneWidget);
        expect(find.text(longPasswordMessage), findsOneWidget);
      });
    });

    group('non-empty validator', () {
      setUp(() {
        testWidget = builder(PasswordValidators.isNotEmpty);
      });

      testWidgets('starts with no validation errors', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(testWidget);

        expect(find.text('Password'), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
      });

      testWidgets('shows no error with valid password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const validPassword = 'kJds;f90sZ.kd"!';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, validPassword);
        await tester.pump();

        expect(find.text(validPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
        expect(find.text(longPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(validPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
        expect(find.text(longPasswordMessage), findsNothing);
      });

      testWidgets('shows error with empty password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const shortPassword = '';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, shortPassword);
        await tester.pump();

        expect(find.text(emptyPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(emptyPasswordMessage), findsOneWidget);
      });

      testWidgets('shows no error with short password', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        const shortPassword = 'a';
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextFormField).first, shortPassword);
        await tester.pump();

        expect(find.text(shortPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);

        // Change to the second form field to force the focus to change
        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();

        expect(find.text(shortPassword), findsOneWidget);
        expect(find.text(shortPasswordMessage), findsNothing);
      });
    });
  });
}

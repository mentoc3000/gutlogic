// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/widgets/cards/notes_card.dart';

import '../util/test_overlay.dart';

void main() {
  group('NotesCard', () {
    // testWidgets('displays default value', (WidgetTester tester) async {
    //   // Build our app and trigger a frame.
    //   await tester.pumpWidget(overlay(child: QuantityView()));

    //   expect(find.text('Amount'), findsOneWidget);
    //   expect(find.text('Units'), findsOneWidget);
    // });

    testWidgets('displays initial value', (WidgetTester tester) async {
      const notes = 'Delicious';
      final controller = TextEditingController(text: notes);
      final notesTile = NotesCard(controller: controller);

      // Build our app and trigger a frame.
      await tester.pumpWidget(TestOverlay(child: notesTile));

      expect(find.text(notes), findsOneWidget);
    });

    testWidgets('updates value', (WidgetTester tester) async {
      const initialNotes = 'Delicious';
      var notes = initialNotes;
      final controller = TextEditingController(text: notes);
      final notesTile = NotesCard(
        controller: controller,
        onChanged: (newNotes) => notes = newNotes,
      );

      // Build our app and trigger a frame.
      await tester.pumpWidget(TestOverlay(child: notesTile));

      const newNotes = 'Terrible';
      await tester.enterText(find.byType(TextField).first, newNotes);

      expect(find.text(initialNotes), findsNothing);
      expect(find.text(newNotes), findsOneWidget);
      expect(notes, newNotes);
    });
  });
}

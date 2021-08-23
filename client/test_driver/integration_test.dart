import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/main.dart' as app;
// ignore: import_of_legacy_library_into_null_safe
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gut Logic App', () {
    testWidgets('changes tabs', (WidgetTester tester) async {
      app.main();

      // TODO WidgetTester has no obvious waitFor analog
      // await driver.waitFor(find.text('Account'));

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // TODO verify we are on the account page

      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      // TODO verify we are on the timeline

      await tester.tap(find.text('Pantry'));
      await tester.pumpAndSettle();

      // TODO verify we are on the pantry
    });
  });
}

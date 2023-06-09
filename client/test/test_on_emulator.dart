import './flutter_test_config.dart';
import './pages/diary_page_test.dart' as t;

/// Run a test on an emulator
///   1. Replace the imported test file with the one you want to test
///   2. Run command flutter run --flavor development -t ./test/test_on_emulator.dart
void main() async {
  await testExecutable(t.main);
}

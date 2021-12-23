import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:test/test.dart';

void main() {
  group('Sensitivity', () {
    test('is combinable', () {
      final sensitivity1 = Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.aggregation);
      final sensitivity2 = Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user);
      final sensitivitySum = Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.aggregation);
      expect(Sensitivity.combine(sensitivity1, sensitivity2), sensitivitySum);
    });
  });
}

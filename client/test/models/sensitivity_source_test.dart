import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:test/test.dart';

void main() {
  group('SensitivitySource', () {
    test('is combinable', () {
      expect(SensitivitySource.combine(SensitivitySource.none, SensitivitySource.none), SensitivitySource.none);
      expect(SensitivitySource.combine(SensitivitySource.user, SensitivitySource.user), SensitivitySource.user);
      expect(SensitivitySource.combine(SensitivitySource.aggregation, SensitivitySource.aggregation),
          SensitivitySource.aggregation);
      expect(SensitivitySource.combine(SensitivitySource.none, SensitivitySource.user), SensitivitySource.user);
      expect(SensitivitySource.combine(SensitivitySource.none, SensitivitySource.aggregation),
          SensitivitySource.aggregation);
      expect(SensitivitySource.combine(SensitivitySource.user, SensitivitySource.aggregation),
          SensitivitySource.aggregation);
    });
  });
}

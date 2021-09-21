import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/resources/sensitivity/models/reaction.dart';
import 'package:gutlogic/resources/sensitivity/models/sensitivity_steps.dart';
import 'package:test/test.dart';

void main() {
  group('SensitivitySteps', () {
    const epsilon = 1E-12;

    test('has no steps for empty reaction list', () {
      final steps = SensitivitySteps.fromReactions(<Reaction>[]);

      expect(steps.interpolate(0), SensitivityLevel.unknown);
      expect(steps.interpolate(double.infinity), SensitivityLevel.unknown);
    });

    test('builds steps from all key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 5, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 7, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 8, sensitivityLevel: SensitivityLevel.severe),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 10, sensitivityLevel: SensitivityLevel.severe),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.none);

      expect(steps.interpolate(1), SensitivityLevel.mild);
      expect(steps.interpolate(3 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(3), SensitivityLevel.moderate);
      expect(steps.interpolate(7 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(7), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with no severe key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 8, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 10, sensitivityLevel: SensitivityLevel.moderate),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.none);

      expect(steps.interpolate(1), SensitivityLevel.mild);
      expect(steps.interpolate(3 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(3), SensitivityLevel.moderate);
      expect(steps.interpolate(15 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(15), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with no moderate key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 8, sensitivityLevel: SensitivityLevel.severe),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 10, sensitivityLevel: SensitivityLevel.severe),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.none);

      expect(steps.interpolate(1), SensitivityLevel.mild);
      expect(steps.interpolate(3 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(3), SensitivityLevel.moderate);
      expect(steps.interpolate(5.5 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(5.5), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with no mild key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 8, sensitivityLevel: SensitivityLevel.severe),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 10, sensitivityLevel: SensitivityLevel.severe),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.none);

      expect(steps.interpolate(1), SensitivityLevel.mild);
      expect(steps.interpolate(2 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(2), SensitivityLevel.moderate);
      expect(steps.interpolate(3 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(3), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with no none key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 8, sensitivityLevel: SensitivityLevel.severe),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 10, sensitivityLevel: SensitivityLevel.severe),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.mild);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(1), SensitivityLevel.moderate);
      expect(steps.interpolate(3 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(3), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with no mild or severe key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.moderate),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.none);

      expect(steps.interpolate(1), SensitivityLevel.mild);
      expect(steps.interpolate(2 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(2), SensitivityLevel.moderate);
      expect(steps.interpolate(13.5 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(13.5), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with no mild or moderate key points', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.severe),
        Reaction(dose: 5, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 6, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 9, sensitivityLevel: SensitivityLevel.severe),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(1 - epsilon), SensitivityLevel.none);

      expect(steps.interpolate(1), SensitivityLevel.mild);
      expect(steps.interpolate(2 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(2), SensitivityLevel.moderate);
      expect(steps.interpolate(3 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(3), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('has no steps for only unknowns', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.unknown),
      ]);

      expect(steps, SensitivitySteps.unknown);
      expect(steps.interpolate(0), SensitivityLevel.unknown);
      expect(steps.interpolate(double.infinity), SensitivityLevel.unknown);
    });

    test('builds steps with only none reactions', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.none),
      ]);

      expect(steps, SensitivitySteps.none);
      expect(steps.interpolate(0), SensitivityLevel.none);
      expect(steps.interpolate(double.infinity), SensitivityLevel.none);
    });

    test('builds steps with only mild reactions', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.mild),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.mild);
      expect(steps.interpolate(6 - epsilon), SensitivityLevel.mild);

      expect(steps.interpolate(6), SensitivityLevel.moderate);
      expect(steps.interpolate(9 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(9), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with only moderate reactions', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.moderate),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.moderate),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.moderate);
      expect(steps.interpolate(6 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(6), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('builds steps with only severe reactions', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.severe),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.severe),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('uses the highest sensitivity reaction for same dose', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.moderate),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.moderate);
      expect(steps.interpolate(6 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(6), SensitivityLevel.severe);
      expect(steps.interpolate(6 + double.infinity), SensitivityLevel.severe);
    });

    test('ignore lower sensitivities for doses above higher sensitivities', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 4, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 3, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 2, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 1, sensitivityLevel: SensitivityLevel.moderate),
      ]);

      expect(steps.interpolate(0), SensitivityLevel.moderate);
      expect(steps.interpolate(1.5 - epsilon), SensitivityLevel.moderate);

      expect(steps.interpolate(1.5), SensitivityLevel.severe);
      expect(steps.interpolate(double.infinity), SensitivityLevel.severe);
    });

    test('ignore zero doses', () {
      final steps = SensitivitySteps.fromReactions([
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.unknown),
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.none),
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.mild),
        Reaction(dose: 0, sensitivityLevel: SensitivityLevel.moderate),
      ]);

      expect(steps, SensitivitySteps.unknown);
      expect(steps.interpolate(0), SensitivityLevel.unknown);
      expect(steps.interpolate(double.infinity), SensitivityLevel.unknown);
    });
  });
}

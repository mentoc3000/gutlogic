import '../../../models/food/food.dart';
import '../../../models/irritant.dart';
import '../../../models/sensitivity/sensitivity_level.dart';
import 'reaction.dart';
import 'sensitivity_steps.dart';

class SensitivityProfile {
  final Map<String, SensitivitySteps> _profile;

  SensitivityProfile._(this._profile);

  factory SensitivityProfile.unknown() {
    return SensitivityProfile._({});
  }

  factory SensitivityProfile.fromCensus(Map<String, Iterable<Reaction>> census) {
    final profile = census.map((irritant, reactions) => MapEntry(irritant, SensitivitySteps.fromReactions(reactions)));
    return SensitivityProfile._(profile);
  }

  SensitivityLevel evaluateFood(Food food) {
    final irritants = food.irritants;
    if (irritants == null || irritants.isEmpty) return SensitivityLevel.unknown;
    return irritants.map(evaluateIrritant).fold<SensitivityLevel>(SensitivityLevel.none, SensitivityLevel.combine);
  }

  SensitivityLevel evaluateIrritant(Irritant irritant) {
    if (!_profile.containsKey(irritant.name)) return SensitivityLevel.unknown;
    if (irritant.concentration == null) return SensitivityLevel.unknown;

    final steps = _profile[irritant.name]!;
    final dose = irritant.concentration! * Reaction.defaultServingSize;
    return steps.interpolate(dose);
  }
}

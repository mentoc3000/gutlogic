import '../../../models/sensitivity/sensitivity_level.dart';

class Reaction {
  final double dose;
  final SensitivityLevel sensitivityLevel;
  static const double defaultServingSize = 100;

  Reaction({required this.dose, required this.sensitivityLevel});
}

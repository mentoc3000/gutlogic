import 'package:flutter/widgets.dart';

import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../style/gl_text_style.dart';
import '../../../widgets/cards/push_card.dart';
import '../../../widgets/sensitivity_indicator.dart';

class MealElementSensitivityCard extends StatelessWidget {
  final SensitivityLevel sensitivityLevel;
  final VoidCallback? onTap;

  const MealElementSensitivityCard({Key? key, SensitivityLevel? sensitivityLevel, this.onTap})
      : sensitivityLevel = sensitivityLevel ?? SensitivityLevel.unknown,
        super(key: key);

  String get _label {
    switch (sensitivityLevel) {
      case SensitivityLevel.none:
        return 'No sensitivity';
      case SensitivityLevel.mild:
        return 'Mild sensitivity';
      case SensitivityLevel.moderate:
        return 'Moderate sensitivity';
      case SensitivityLevel.severe:
        return 'Severe sensitivity';
      default:
        return 'Unknown sensitivity';
    }
  }

  @override
  Widget build(BuildContext context) {
    const style = tileSubheadingStyle;
    return PushCard(
      child: Row(
        children: [
          SensitivityIndicator(sensitivityLevel),
          const SizedBox(width: 8),
          Text(_label, style: style),
        ],
      ),
      onTap: onTap,
    );
  }
}

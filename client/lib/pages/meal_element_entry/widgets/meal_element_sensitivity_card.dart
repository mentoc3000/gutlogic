import 'package:flutter/widgets.dart';

import '../../../models/sensitivity.dart';
import '../../../style/gl_theme.dart';
import '../../../widgets/cards/push_card.dart';
import '../../../widgets/sensitivity_indicator.dart';

class MealElementSensitivityCard extends StatelessWidget {
  final Sensitivity sensitivity;
  final VoidCallback onTap;

  const MealElementSensitivityCard({Key key, @required this.sensitivity, @required this.onTap}) : super(key: key);

  // move labels to Sensitivity class
  String get _label {
    switch (sensitivity) {
      case Sensitivity.none:
        return 'None';
      case Sensitivity.mild:
        return 'Mild';
      case Sensitivity.moderate:
        return 'Moderate';
      case Sensitivity.severe:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = tileSubheadingTheme;
    return PushCard(
      child: Row(
        children: [
          SensitivityIndicator(sensitivity ?? Sensitivity.unknown),
          const SizedBox(width: 8),
          Text('$_label sensitivity', style: style),
        ],
      ),
      onTap: onTap,
    );
  }
}

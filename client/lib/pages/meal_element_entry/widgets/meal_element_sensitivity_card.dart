import 'package:flutter/widgets.dart';

import '../../../models/sensitivity.dart';
import '../../../style/gl_theme.dart';
import '../../../widgets/cards/push_card.dart';
import '../../../widgets/sensitivity_indicator.dart';

class MealElementSensitivityCard extends StatelessWidget {
  final Sensitivity sensitivity;
  final VoidCallback onTap;

  const MealElementSensitivityCard({Key key, @required this.sensitivity, @required this.onTap}) : super(key: key);

  String get _label {
    switch (sensitivity) {
      case Sensitivity.none:
        return 'No sensitivity';
      case Sensitivity.mild:
        return 'Mild sensitivity';
      case Sensitivity.moderate:
        return 'Moderate sensitivity';
      case Sensitivity.severe:
        return 'Severe sensitivity';
      default:
        return 'Unknown sensitivity';
    }
  }

  @override
  Widget build(BuildContext context) {
    const style = tileSubheadingTheme;
    return PushCard(
      child: Row(
        children: [
          SensitivityIndicator(sensitivity ?? Sensitivity.unknown),
          const SizedBox(width: 8),
          Text(_label, style: style),
        ],
      ),
      onTap: onTap,
    );
  }
}

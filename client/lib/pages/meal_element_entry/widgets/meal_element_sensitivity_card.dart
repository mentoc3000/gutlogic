import 'package:flutter/widgets.dart';

import '../../../models/sensitivity/sensitivity.dart';
import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../style/gl_text_style.dart';
import '../../../widgets/cards/push_card.dart';
import '../../../widgets/sensitivity_indicator.dart';

class MealElementSensitivityCard extends StatelessWidget {
  final Future<Sensitivity> sensitivity;
  final VoidCallback? onTap;

  const MealElementSensitivityCard({Key? key, required this.sensitivity, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = tileSubheadingStyle;
    return FutureBuilder<Sensitivity>(
      future: sensitivity,
      builder: (context, snapshot) {
        final sensitivity = snapshot.data;
        late final String _label;
        switch (sensitivity?.level) {
          case SensitivityLevel.none:
            _label = 'No sensitivity';
            break;
          case SensitivityLevel.mild:
            _label = 'Mild sensitivity';
            break;
          case SensitivityLevel.moderate:
            _label = 'Moderate sensitivity';
            break;
          case SensitivityLevel.severe:
            _label = 'Severe sensitivity';
            break;
          case SensitivityLevel.unknown:
            _label = 'Severe sensitivity';
            break;
          default:
            _label = '';
        }

        return PushCard(
          child: Row(
            children: [
              SensitivityIndicator(this.sensitivity),
              const SizedBox(width: 8),
              Text(_label, style: style),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }
}

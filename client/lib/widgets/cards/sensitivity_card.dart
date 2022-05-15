import 'package:flutter/widgets.dart';

import '../../models/sensitivity/sensitivity.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../../models/sensitivity/sensitivity_source.dart';
import '../../style/gl_text_style.dart';
import '../sensitivity_indicator.dart';
import 'push_card.dart';

class SensitivityCard extends StatelessWidget {
  final Future<Sensitivity> sensitivity;
  final VoidCallback? onTap;

  const SensitivityCard({Key? key, required this.sensitivity, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = tileSubheadingStyle;
    return FutureBuilder<Sensitivity>(
      future: sensitivity,
      builder: (context, snapshot) {
        final sensitivity = snapshot.data;
        late final String label;
        if (sensitivity?.level == SensitivityLevel.none) {
          label = 'No sensitivity';
        } else if (sensitivity?.level == SensitivityLevel.mild) {
          label = 'Mild sensitivity';
        } else if (sensitivity?.level == SensitivityLevel.moderate) {
          label = 'Moderate sensitivity';
        } else if (sensitivity?.level == SensitivityLevel.severe) {
          label = 'Severe sensitivity';
        } else if (sensitivity == Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user)) {
          label = 'Unknown sensitivity';
        } else {
          label = 'Add to Pantry';
        }

        return PushCard(
          onTap: onTap,
          child: Row(
            children: [
              SensitivityIndicator(this.sensitivity),
              const SizedBox(width: 8),
              Text(label, style: style),
            ],
          ),
        );
      },
    );
  }
}

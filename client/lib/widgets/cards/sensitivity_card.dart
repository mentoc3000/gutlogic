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
        late final String _label;
        if (sensitivity?.level == SensitivityLevel.none) {
          _label = 'No sensitivity';
        } else if (sensitivity?.level == SensitivityLevel.mild) {
          _label = 'Mild sensitivity';
        } else if (sensitivity?.level == SensitivityLevel.moderate) {
          _label = 'Moderate sensitivity';
        } else if (sensitivity?.level == SensitivityLevel.severe) {
          _label = 'Severe sensitivity';
        } else if (sensitivity == Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user)) {
          _label = 'Unknown sensitivity';
        } else {
          _label = 'Add to Pantry';
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

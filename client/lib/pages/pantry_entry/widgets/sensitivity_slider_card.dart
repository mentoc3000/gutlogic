import 'package:flutter/material.dart';

import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/cards/headed_card.dart';

class SensitivitySlider extends StatefulWidget {
  final SensitivityLevel sensitivityLevel;
  final void Function(SensitivityLevel)? onChanged;

  const SensitivitySlider({required this.sensitivityLevel, this.onChanged});

  @override
  State<SensitivitySlider> createState() => _SensitivitySliderState();
}

class _SensitivitySliderState extends State<SensitivitySlider> {
  late SensitivityLevel sensitivityLevel;

  Color get _color => GLColors.fromSensitivityLevel(sensitivityLevel);

  // move labels to Sensitivity class
  String get _label {
    switch (sensitivityLevel) {
      case SensitivityLevel.none:
        return 'None';
      case SensitivityLevel.mild:
        return 'Mild';
      case SensitivityLevel.moderate:
        return 'Moderate';
      case SensitivityLevel.severe:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }

  _SensitivitySliderState();

  @override
  void initState() {
    super.initState();
    sensitivityLevel = widget.sensitivityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Sensitivity',
      content: Column(
        children: [
          Slider(
            min: 0,
            max: 4,
            divisions: 4,
            value: sensitivityToSliderValue(sensitivityLevel),
            activeColor: _color,
            onChanged: onSensitivityChanged,
            onChangeEnd: onSensitivityChangeEnd,
          ),
          Text(_label),
        ],
      ),
    );
  }

  double sensitivityToSliderValue(SensitivityLevel sensitivityLevel) => sensitivityLevel.toInt() + 1;

  SensitivityLevel sliderValueToSensitivity(double value) => SensitivityLevel.fromNum(value - 1);

  void onSensitivityChanged(double value) {
    setState(() {
      sensitivityLevel = sliderValueToSensitivity(value);
    });
  }

  void onSensitivityChangeEnd(double value) {
    setState(() {
      widget.onChanged?.call(sliderValueToSensitivity(value));
    });
  }
}

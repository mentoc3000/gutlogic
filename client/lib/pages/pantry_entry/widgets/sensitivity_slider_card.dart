import 'package:flutter/material.dart';

import '../../../models/sensitivity.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/cards/headed_card.dart';

class SensitivitySlider extends StatefulWidget {
  final Sensitivity sensitivity;
  final void Function(Sensitivity)? onChanged;

  const SensitivitySlider({required this.sensitivity, this.onChanged});

  @override
  _SensitivitySliderState createState() => _SensitivitySliderState(sensitivity: sensitivity);
}

class _SensitivitySliderState extends State<SensitivitySlider> {
  Sensitivity sensitivity;

  Color get _color => GLColors.fromSensitivity(sensitivity);

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

  _SensitivitySliderState({required this.sensitivity});

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
            value: sensitivityToSliderValue(sensitivity),
            activeColor: _color,
            onChanged: onSensitivityChanged,
            onChangeEnd: onSensitivityChangeEnd,
          ),
          Text(_label),
        ],
      ),
    );
  }

  double sensitivityToSliderValue(Sensitivity sensitivity) => sensitivity.toInt() + 1;

  Sensitivity sliderValueToSensitivity(double value) => Sensitivity.fromNum(value - 1);

  void onSensitivityChanged(double value) {
    setState(() {
      sensitivity = sliderValueToSensitivity(value);
    });
  }

  void onSensitivityChangeEnd(double value) {
    setState(() {
      widget.onChanged?.call(sliderValueToSensitivity(value));
    });
  }
}

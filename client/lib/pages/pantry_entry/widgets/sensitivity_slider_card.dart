import 'package:flutter/material.dart';

import '../../../models/sensitivity.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/cards/headed_card.dart';
import '../../../widgets/gl_icons.dart';

class SensitivitySlider extends StatefulWidget {
  final Sensitivity sensitivityLevel;
  final Function(Sensitivity) onChanged;

  const SensitivitySlider({this.sensitivityLevel, this.onChanged});

  @override
  _SensitivitySliderState createState() => _SensitivitySliderState();
}

class _SensitivitySliderState extends State<SensitivitySlider> {
  Sensitivity _sensitivity;
  Color get _color => GLColors.fromSensitivity(_sensitivity);

  // move labels to Sensitivity class
  String get _label {
    switch (_sensitivity) {
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
  void initState() {
    super.initState();
    _sensitivity = widget.sensitivityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Sensitivity',
      content: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                Slider(
                  min: 0,
                  max: 3,
                  divisions: 3,
                  value: _sensitivityToSliderValue(_sensitivity),
                  activeColor: _color,
                  onChanged: (value) => setState(() {
                    _sensitivity = _sliderValueToSensitivity(value);
                  }),
                  onChangeEnd: onSensitivityChange,
                ),
                Text(_label),
              ],
            ),
          ),
          FlatButton(
            onPressed: onSensitivityClear,
            child: const Icon(GLIcons.clear),
          ),
        ],
      ),
    );
  }

  void onSensitivityClear() => setState(() {
        if (_sensitivity != Sensitivity.unknown) {
          _sensitivity = Sensitivity.unknown;
          widget.onChanged(_sensitivity);
        }
      });

  void onSensitivityChange(double newValue) => setState(() => widget.onChanged(_sliderValueToSensitivity(newValue)));
}

Sensitivity _sliderValueToSensitivity(num value) {
  switch (value) {
    case 0:
      return Sensitivity.none;
    case 1:
      return Sensitivity.mild;
    case 2:
      return Sensitivity.moderate;
    case 3:
      return Sensitivity.severe;
    default:
      return Sensitivity.unknown;
  }
}

double _sensitivityToSliderValue(Sensitivity sensitivity) {
  switch (sensitivity) {
    case Sensitivity.none:
      return 0;
    case Sensitivity.mild:
      return 1;
    case Sensitivity.moderate:
      return 2;
    case Sensitivity.severe:
      return 3;
    default:
      return 0;
  }
}

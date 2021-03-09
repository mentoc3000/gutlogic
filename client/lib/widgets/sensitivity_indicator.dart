import 'package:flutter/material.dart';

import '../models/sensitivity.dart';
import '../style/gl_colors.dart';

class SensitivityIndicator extends StatelessWidget {
  final Sensitivity sensitivity;
  final Color borderColor;
  final Color fillColor;
  final double size;

  SensitivityIndicator(this.sensitivity, {this.size = 16})
      : borderColor = _borderColor(sensitivity),
        fillColor = _fillColor(sensitivity);

  static Color _fillColor(Sensitivity sensitivity) => GLColors.fromSensitivity(sensitivity);

  static Color _borderColor(Sensitivity sensitivity) => _fillColor(sensitivity);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            width: 5.0,
            color: borderColor,
          ),
          color: fillColor),
    );
  }
}

class SensitivityIndicatorLarge extends StatelessWidget {
  final Sensitivity sensitivity;

  SensitivityIndicatorLarge({this.sensitivity});

  @override
  Widget build(BuildContext context) => SensitivityIndicator(sensitivity, size: 30.0);
}

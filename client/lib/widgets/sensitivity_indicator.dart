import 'package:flutter/material.dart';

import '../models/sensitivity/sensitivity_level.dart';
import '../style/gl_colors.dart';

class SensitivityIndicator extends StatelessWidget {
  final SensitivityLevel sensitivityLevel;
  final Color borderColor;
  final Color fillColor;
  final double size;

  SensitivityIndicator(this.sensitivityLevel, {this.size = 16})
      : borderColor = _borderColor(sensitivityLevel),
        fillColor = _fillColor(sensitivityLevel);

  static Color _fillColor(SensitivityLevel sensitivityLevel) => GLColors.fromSensitivityLevel(sensitivityLevel);

  static Color _borderColor(SensitivityLevel sensitivityLevel) => _fillColor(sensitivityLevel);

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
  final SensitivityLevel sensitivityLevel;

  SensitivityIndicatorLarge({required this.sensitivityLevel});

  @override
  Widget build(BuildContext context) => SensitivityIndicator(sensitivityLevel, size: 30.0);
}

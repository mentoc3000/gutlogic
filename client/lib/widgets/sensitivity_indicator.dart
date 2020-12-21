import 'package:flutter/material.dart';
import '../models/sensitivity.dart';

class SensitivityIndicator extends StatelessWidget {
  final Sensitivity sensitivity;
  final Color borderColor;
  final Color fillColor;
  final double size;

  SensitivityIndicator({this.sensitivity, this.size})
      : borderColor = _borderColor(sensitivity),
        fillColor = _fillColor(sensitivity);

  static Color _borderColor(Sensitivity sensitivity) {
    Color color;
    switch (sensitivity) {
      case Sensitivity.unknown:
        {
          color = Colors.grey;
          break;
        }
      case Sensitivity.none:
        {
          color = Colors.green;
          break;
        }
      case Sensitivity.minor:
        {
          color = Colors.orange;
          break;
        }
      case Sensitivity.major:
        {
          color = Colors.red;
          break;
        }
    }
    return color;
  }

  static Color _fillColor(Sensitivity sensitivity) {
    Color color;
    switch (sensitivity) {
      case Sensitivity.unknown:
        {
          color = Colors.grey;
          break;
        }
      case Sensitivity.none:
        {
          color = Colors.green;
          break;
        }
      case Sensitivity.minor:
        {
          color = Colors.orange;
          break;
        }
      case Sensitivity.major:
        {
          color = Colors.red;
          break;
        }
    }
    return color;
  }

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
  Widget build(BuildContext context) => SensitivityIndicator(sensitivity: sensitivity, size: 30.0);
}

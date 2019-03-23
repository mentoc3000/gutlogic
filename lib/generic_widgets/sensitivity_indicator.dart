import 'package:flutter/material.dart';
import 'package:gut_ai/model/sensitivity.dart';

class SensitivityIndicator extends StatelessWidget {
  final Sensitivity sensitivity;
  final Color borderColor;
  final Color fillColor;
  final double size;

  SensitivityIndicator({this.sensitivity, this.size}) :
    this.borderColor = _borderColor(sensitivity),
    this.fillColor =_fillColor(sensitivity);

  static Color _borderColor(Sensitivity sensitivity) {
    Color color;
    switch (sensitivity) {
      case Sensitivity.Unknown: {
        color = Colors.grey;
        break;
      }
      case Sensitivity.None: {
        color = Colors.green;
        break;
      }
      case Sensitivity.Minor: {
        color = Colors.orange;
        break;
      }
      case Sensitivity.Major: {
        color = Colors.red;
        break;
      }
    } 
    return color;
  }

  static Color _fillColor(Sensitivity sensitivity) {
    Color color;
    switch (sensitivity) {
      case Sensitivity.Unknown: {
        color = Colors.grey;
        break;
      }
      case Sensitivity.None: {
        color = Colors.green;
        break;
      }
      case Sensitivity.Minor: {
        color = Colors.orange;
        break;
      }
      case Sensitivity.Major: {
        color = Colors.red;
        break;
      }
    } 
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: this.size,
      height: this.size,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(25.0),
        border: new Border.all(
          width: 5.0,
          color: this.borderColor,
        ),
        color: this.fillColor
      ),
    );
  }
}

class SensitivityIndicatorLarge extends StatelessWidget {
  final Sensitivity sensitivity;
  SensitivityIndicatorLarge({this.sensitivity});

  @override
  Widget build(BuildContext context) => SensitivityIndicator(sensitivity: this.sensitivity, size: 30.0);
}
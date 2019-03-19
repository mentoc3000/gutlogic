import 'package:flutter/material.dart';
import 'package:gut_ai/model/sensitivity.dart';

class SensitivityIndicatorLarge extends StatelessWidget {
  final Sensitivity sensitivity;
  final Color borderColor;
  final Color fillColor;

  SensitivityIndicatorLarge({this.sensitivity}) :
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
      width: 30.0,
      height: 30.0,
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

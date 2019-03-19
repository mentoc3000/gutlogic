import 'package:flutter/material.dart';
import 'package:gut_ai/model/sensitivity.dart';

class SensitivityIndicatorLarge extends StatelessWidget {
  final Sensitivity sensitivity;

  SensitivityIndicatorLarge({this.sensitivity});

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 30.0,
      height: 30.0,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(25.0),
        border: new Border.all(
          width: 5.0,
          color: Colors.red,
        ),
        color: Colors.green
      ),
    );
  }
}

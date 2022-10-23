import 'package:flutter/material.dart';

import '../models/sensitivity/sensitivity_level.dart';
export 'package:flutter/material.dart' show Color;

class GLColors {
  static const green = Color(0xFF0AD488);
  // static const lightGreen = Color(0xFF13EBA2); // Color from 2 color logo
  static const lightGreen = Color(0xFF63FFB8);
  static const darkGreen = Color(0xFF00A15A);
  static const gold = Color(0xFFF7B32B);
  static const lightGold = Color(0xFFFFE560);
  static const darkGold = Color(0xFFBF8400);
  static const gray = Colors.grey;
  static Color lightestGray = Colors.grey.shade50;
  static Color lighterGray = Colors.grey.shade300;
  static Color darkGray = Colors.grey.shade800;
  static const red = Color(0xFFA30000);
  static const purple = Color(0xFF4C1E4F);
  static const blue = Color(0xFF004777);
  static const yellow = Colors.yellow;
  static const orange = Colors.orange;

  static const googleBlue = Color(0xFF4285F4);
  static const edamamGreen = Color(0xFF79CA38);

  static const cta = gold; // Call to action
  static Color onCta = Colors.grey.shade900;
  static const info = Colors.blue;
  static const cancel = Colors.redAccent;

  static const food = Colors.blue;
  static const bowelMovement = Colors.purple;
  static const symptom = Colors.red;

  static const development = Colors.green;
  static const production = Colors.red;

  static const transparent = Colors.transparent;
  static const black = Colors.black;
  static const white = Colors.white;

  static const mildSeverity = Color(0xFFfee385); // happy face color
  static const severeSeverity = Color(0xFFE13D5E); // angry face color

  static Color fromSensitivityLevel(SensitivityLevel sensitivityLevel) {
    switch (sensitivityLevel) {
      case SensitivityLevel.none:
        return Colors.green;
      case SensitivityLevel.mild:
        return Colors.yellow;
      case SensitivityLevel.moderate:
        return Colors.orange;
      case SensitivityLevel.severe:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

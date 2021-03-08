import 'package:flutter/material.dart';
import 'gl_color_scheme.dart';
import 'gl_colors.dart';

// ThemeData will be updated in future version of Flutter, with breaking changes.
// https://docs.google.com/document/d/1kzIOQN4QYfVsc5lMZgy_A-FWGXBAJBMySGqZqsJytcE

final ThemeData glTheme = ThemeData(
  colorScheme: glColorScheme,
  scaffoldBackgroundColor: glColorScheme.background,
  primaryColor: glColorScheme.primary,
  accentColor: glColorScheme.secondary,
  hintColor: GLColors.green,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: glColorScheme.primary),
  ),
  canvasColor: GLColors.transparent,
);

const tileHeadingTheme = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

const tileSubheadingTheme = TextStyle(fontSize: 16.0);

const brightnessOnBackground = Brightness.light;

const brightnessOnPrimary = Brightness.dark;

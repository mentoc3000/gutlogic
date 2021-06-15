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

final ThemeData searchDelegateTheme = glTheme.copyWith(
  textTheme: glTheme.textTheme.copyWith(
    headline6: glTheme.textTheme.headline6?.copyWith(color: glTheme.colorScheme.onPrimary),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: glColorScheme.onPrimary,
    selectionColor: glColorScheme.onPrimary.withOpacity(0.5),
    selectionHandleColor: glColorScheme.onPrimary,
  ),
);

const brightnessOnBackground = Brightness.light;

const brightnessOnPrimary = Brightness.dark;

import 'package:flutter/material.dart';

import 'gl_color_scheme.dart';
import 'gl_colors.dart';

final ThemeData glTheme = ThemeData(
  colorScheme: glColorScheme,
  scaffoldBackgroundColor: glColorScheme.background,
  primaryColor: glColorScheme.primary,
  hintColor: GLColors.green,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: glColorScheme.primary),
  ),
  canvasColor: GLColors.transparent,
);

final ThemeData searchDelegateTheme = glTheme.copyWith(
  textTheme: glTheme.textTheme.copyWith(
    titleLarge: glTheme.textTheme.titleLarge?.copyWith(color: glTheme.colorScheme.onPrimary),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: glColorScheme.onPrimary,
    selectionColor: glColorScheme.onPrimary.withOpacity(0.5),
    selectionHandleColor: glColorScheme.onPrimary,
  ),
);

const brightnessOnBackground = Brightness.light;

const brightnessOnPrimary = Brightness.dark;

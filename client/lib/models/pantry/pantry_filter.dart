import 'package:built_value/built_value.dart';

import '../pantry/pantry_entry.dart';
import '../sensitivity/sensitivity_level.dart';

part 'pantry_filter.g.dart';

abstract class PantryFilter implements Built<PantryFilter, PantryFilterBuilder> {
  bool get showUnknownSensitivity;
  bool get showNoneSensitivity;
  bool get showMildSensitivity;
  bool get showModerateSensitivity;
  bool get showSevereSensitivity;

  PantryFilter._();

  factory PantryFilter({
    bool showUnknownSensitivity = true,
    bool showNoneSensitivity = true,
    bool showMildSensitivity = true,
    bool showModerateSensitivity = true,
    bool showSevereSensitivity = true,
  }) =>
      _$PantryFilter._(
        showUnknownSensitivity: showUnknownSensitivity,
        showNoneSensitivity: showNoneSensitivity,
        showMildSensitivity: showMildSensitivity,
        showModerateSensitivity: showModerateSensitivity,
        showSevereSensitivity: showSevereSensitivity,
      );

  factory PantryFilter.all() => PantryFilter();

  PantryFilter show(SensitivityLevel level) => _setVisibility(level, true);
  PantryFilter hide(SensitivityLevel level) => _setVisibility(level, false);
  PantryFilter toggle(SensitivityLevel level) => _setVisibility(level, !isShown(level));

  PantryFilter _setVisibility(SensitivityLevel level, bool value) {
    switch (level) {
      case SensitivityLevel.unknown:
        return rebuild((b) => b.showUnknownSensitivity = value);
      case SensitivityLevel.none:
        return rebuild((b) => b.showNoneSensitivity = value);
      case SensitivityLevel.mild:
        return rebuild((b) => b.showMildSensitivity = value);
      case SensitivityLevel.moderate:
        return rebuild((b) => b.showModerateSensitivity = value);
      case SensitivityLevel.severe:
        return rebuild((b) => b.showSevereSensitivity = value);
      default:
        // Should never be reached
        throw ArgumentError.value(level);
    }
  }

  bool isShown(SensitivityLevel level) {
    switch (level) {
      case SensitivityLevel.unknown:
        return showUnknownSensitivity;
      case SensitivityLevel.none:
        return showNoneSensitivity;
      case SensitivityLevel.mild:
        return showMildSensitivity;
      case SensitivityLevel.moderate:
        return showModerateSensitivity;
      case SensitivityLevel.severe:
        return showSevereSensitivity;
      default:
        // Should never be reached
        throw ArgumentError.value(level);
    }
  }

  bool isIncluded(PantryEntry pantryEntry) {
    switch (pantryEntry.sensitivity.level) {
      case SensitivityLevel.unknown:
        if (!showUnknownSensitivity) return false;
        break;
      case SensitivityLevel.none:
        if (!showNoneSensitivity) return false;
        break;
      case SensitivityLevel.mild:
        if (!showMildSensitivity) return false;
        break;
      case SensitivityLevel.moderate:
        if (!showModerateSensitivity) return false;
        break;
      case SensitivityLevel.severe:
        if (!showSevereSensitivity) return false;
        break;
      default:
        break;
    }
    return true;
  }
}

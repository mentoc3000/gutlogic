import 'package:built_value/built_value.dart';

import '../sensitivity.dart';
import 'pantry_entry.dart';

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

  PantryFilter show(Sensitivity sensitivity) => _setVisibility(sensitivity, true);
  PantryFilter hide(Sensitivity sensitivity) => _setVisibility(sensitivity, false);
  PantryFilter toggle(Sensitivity sensitivity) => _setVisibility(sensitivity, !isShown(sensitivity));

  PantryFilter _setVisibility(Sensitivity sensitivity, bool value) {
    switch (sensitivity) {
      case Sensitivity.unknown:
        return rebuild((b) => b.showUnknownSensitivity = value);
      case Sensitivity.none:
        return rebuild((b) => b.showNoneSensitivity = value);
      case Sensitivity.mild:
        return rebuild((b) => b.showMildSensitivity = value);
      case Sensitivity.moderate:
        return rebuild((b) => b.showModerateSensitivity = value);
      case Sensitivity.severe:
        return rebuild((b) => b.showSevereSensitivity = value);
      default:
        // Should never be reached
        throw ArgumentError.value(sensitivity);
    }
  }

  bool isShown(Sensitivity sensitivity) {
    switch (sensitivity) {
      case Sensitivity.unknown:
        return showUnknownSensitivity;
      case Sensitivity.none:
        return showNoneSensitivity;
      case Sensitivity.mild:
        return showMildSensitivity;
      case Sensitivity.moderate:
        return showModerateSensitivity;
      case Sensitivity.severe:
        return showSevereSensitivity;
      default:
        // Should never be reached
        throw ArgumentError.value(sensitivity);
    }
  }

  bool isIncluded(PantryEntry pantryEntry) {
    switch (pantryEntry.sensitivity) {
      case Sensitivity.unknown:
        if (!showUnknownSensitivity) return false;
        break;
      case Sensitivity.none:
        if (!showNoneSensitivity) return false;
        break;
      case Sensitivity.mild:
        if (!showMildSensitivity) return false;
        break;
      case Sensitivity.moderate:
        if (!showModerateSensitivity) return false;
        break;
      case Sensitivity.severe:
        if (!showSevereSensitivity) return false;
        break;
      default:
        break;
    }
    return true;
  }
}

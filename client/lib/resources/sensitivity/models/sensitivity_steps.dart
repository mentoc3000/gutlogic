import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../util/iter_utils.dart';
import 'reaction.dart';

// All sensitivity levels except unknown.
final _reactionSensitivityLevels = List<SensitivityLevel>.unmodifiable(
  SensitivityLevel.list()..remove(SensitivityLevel.unknown),
);

// All sensitivity levels that will cause a reaction.
final _nonzeroSensitivityLevels = List<SensitivityLevel>.unmodifiable(
  SensitivityLevel.list()..remove(SensitivityLevel.unknown)..remove(SensitivityLevel.none),
);

/// The lowest doses to trigger each sensitivity level
class SensitivitySteps {
  final Map<SensitivityLevel, double> _sensitivityMinDoseMap;

  const SensitivitySteps._(Map<SensitivityLevel, double> sensitivityMinDoseMap)
      : _sensitivityMinDoseMap = sensitivityMinDoseMap;

  // A set of sensitivity steps where every dosage returns unknown sensitivity.
  static const SensitivitySteps unknown = SensitivitySteps._({});

  // A set of sensitivity steps where every dosage returns no sensitivity.
  static const SensitivitySteps none = SensitivitySteps._({SensitivityLevel.none: 0});

  factory SensitivitySteps.fromReactions(Iterable<Reaction> rs) {
    // Ignore reactions with zero dosage or unknown sensitivity level, as we cannot make predictions from them.
    final reactions = rs.where((r) => r.dose > 0 && r.sensitivityLevel != SensitivityLevel.unknown);

    // If remaining reactions are empty the predicted sensitivity is always unknown.
    if (reactions.isEmpty) return SensitivitySteps.unknown;

    // If remaining reactions only contain nones there can never be a reaction (so, infinite min dose).
    if (reactions.all((r) => r.sensitivityLevel == SensitivityLevel.none)) return SensitivitySteps.none;

    // Compute the extents of the reactions. The extents are minimum and maximum doses for a given sensitivity level.
    final extents = ReactionExtents.compute(reactions);

    // Expand the extents into a number of points by linearly interpolating the maximum of the previous extent and
    // the minimum of the next extent. Extrapolate the remaining doses by a constant multiplier. The dose array is
    // then filled with the minimum dose for the sensitivity index.

    final doses = <double>[];

    // When the first reaction is higher than none, assume the min dose for all sensitivities up to that reaction is 0.
    // This means that any dose of this irritant will cause at least the first known reaction sensitivity level.

    while (extents.isNotEmpty && doses.length < extents[0].level.toInt()) {
      doses.add(0.0);
    }

    // Interpolate each reaction extent into one or more min doses. Use the sensitivity level of the extent to find the
    // number of missing min doses in the dose list. For example, the dose list only has a dose for SensitivityLevel.none
    // and the next reaction extent is for SensitivityLevel.severe, so we need add doses for mild, moderate, and severe
    // sensitivities. Interpolate these doses using the maximum dose of the previous reaction extent and the minimum
    // dose of the current reaction extent.

    for (var i = 0; i < extents.length; i++) {
      final steps = (extents[i].level.toInt() - doses.length) + 1;
      final lower = i == 0 ? 0.0 : extents[i - 1].maximum;
      final upper = extents[i].minimum;

      doses.addAll(_generateSensitivitySteps(lower, upper, steps));
    }

    // Extrapolate any remaining doses up to the max sensitivity level.

    const extrapolationFactor = 1.5;

    if (doses.length < _reactionSensitivityLevels.length) {
      // Use the maximum dose of the last extent for the first extrapolation.
      doses.add((extents.isNotEmpty ? extents[extents.length - 1].maximum : 0.0) * extrapolationFactor);
    }

    while (doses.length < _reactionSensitivityLevels.length) {
      // Use the previous extrapolation for the subsequent extrapolations.
      doses.add(doses[doses.length - 1] * extrapolationFactor);
    }

    // Map the dose list with the corresponding sensitivity level.
    return SensitivitySteps._(Map.fromIterables(_reactionSensitivityLevels, doses));
  }

  /// Returns the expected sensitivity of an irritant [dose], based on the reactions used to create the steps.
  ///
  /// Throws an ArgumentError if the [dose] is negative.
  SensitivityLevel interpolate(double dose) {
    if (dose < 0) throw ArgumentError('The irritant dose must be positive.');

    // Special case for no reactions, we err on caution and return unknown.
    if (_sensitivityMinDoseMap.isEmpty) return SensitivityLevel.unknown;

    // Iterate from high to low sensitivity levels where there is a min dose.
    final sensitivities = _nonzeroSensitivityLevels.reversed.where(_sensitivityMinDoseMap.containsKey);

    // Return first (highest) sensitivity level where the dose exceeds the min dose.
    for (final sensitivity in sensitivities) {
      if (_sensitivityMinDoseMap[sensitivity]! <= dose) return sensitivity;
    }

    return SensitivityLevel.none;
  }
}

/// Return an iterable of [steps] values interpolated between a [min] (inclusive) and [max] (exclusive) value.
///
/// Throws an [AssertionError] if [min] is greater than [max].
/// Throws an [AssertionError] if [steps] is zero.
Iterable<double> _generateSensitivitySteps(double min, double max, int steps) sync* {
  assert(min <= max);
  assert(steps >= 1);

  final d = (max - min) / steps.toDouble();

  for (var t = 0; t < steps; t++) {
    yield min + (d * t);
  }
}

class ReactionExtents {
  double minimum;
  double maximum;

  SensitivityLevel level;

  ReactionExtents({
    required this.level,
    required this.minimum,
    required this.maximum,
  });

  void add(double dose) {
    minimum = math.min(minimum, dose);
    maximum = math.max(maximum, dose);
  }

  /// Compute the extents for each sensitivity level in the reaction list. The extents only include reactions less
  /// severe than the minimum dosage of the next highest reaction. There is no overlap between the extents. Returns a
  /// new map.
  static List<ReactionExtents> compute(Iterable<Reaction> reactions) {
    final result = <SensitivityLevel, ReactionExtents>{};

    // Bucket the reactions into a map, keyed by dose. Use the highest sensitivity for each dose.
    final reactionsUniqueByDose = reactions.groupFoldBy<double, Reaction>((r) => r.dose, (fold, r) {
      return (fold is Reaction && r.sensitivityLevel < fold.sensitivityLevel ? fold : r);
    });

    // Sort the reactions by dose to arrive at a flat list of unique sorted reactions.
    final reactionsSortedByDose = reactionsUniqueByDose.values.sorted((a, b) {
      return a.dose.compareTo(b.dose);
    });

    var minimumSensitivityLevel = 0;

    for (final reaction in reactionsSortedByDose) {
      final level = reaction.sensitivityLevel;
      final levelAsInt = level.toInt();

      if (levelAsInt < minimumSensitivityLevel) continue;

      minimumSensitivityLevel = levelAsInt;

      result[level] ??= ReactionExtents(
        level: level,
        minimum: reaction.dose,
        maximum: reaction.dose,
      );

      result[level]?.add(reaction.dose);
    }

    return result.values.toList(growable: false);
  }
}

import 'package:flutter/widgets.dart';

import '../../models/irritant/irritant.dart';
import '../../style/gl_colors.dart';

class IntensityIndicator extends StatelessWidget {
  final int? value;
  static const compartmentCount = 3;
  static const height = 16.0;
  static const width = 100.0;
  static const radius = height / 2;

  const IntensityIndicator(this.value);

  IntensityIndicator.fromIrritant({required Irritant irritant, required Iterable<double> intensityThresholds})
      : value = intensityThresholds.fold<int>(0, (acc, el) => irritant.dosePerServing > el ? acc + 1 : acc);

  /// An intensity indicator with no bars filled
  const IntensityIndicator.empty() : value = 0;

  @override
  Widget build(BuildContext context) {
    final filledBoxes = List.generate(compartmentCount, (i) {
      late final double boxWidth;
      switch (i) {
        case 0:
          boxWidth = width * (i + 1) / compartmentCount + 0.6 * radius; // the 0.6 just makes it look better ¯\_(ツ)_/¯
          break;
        case 1:
          boxWidth = width * (i + 1) / compartmentCount + 0.5 * radius;
          break;
        default:
          boxWidth = width;
      }

      late final Color? color;
      // If value is null, use 0
      if ((value ?? 0) > i) {
        switch (i) {
          case 0:
            color = GLColors.lightGold;
            break;
          case 1:
            color = GLColors.gold;
            break;
          default:
            color = GLColors.darkGold;
        }
      } else {
        color = null;
      }

      return roundedBox(width: boxWidth, showBorder: true, color: color);
    }).reversed.toList();

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        ...filledBoxes,
        roundedBox(width: width, showBorder: true),
      ],
    );
  }

  Widget roundedBox({
    required double width,
    required bool showBorder,
    Color? color,
  }) {
    final decoration = BoxDecoration(
      border: showBorder ? Border.all(width: 1.6, color: GLColors.darkGray) : null,
      borderRadius: const BorderRadius.all(Radius.circular(radius)),
      color: color,
    );

    return Container(
      decoration: decoration,
      width: width,
      height: height,
    );
  }
}

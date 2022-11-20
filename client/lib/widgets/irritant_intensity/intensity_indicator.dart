import 'package:flutter/widgets.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:gutlogic/resources/irritant_service.dart';

import '../../models/irritant/irritant.dart';
import '../../style/gl_colors.dart';

class IntensityIndicator extends StatelessWidget {
  final Intensity intensity;
  static const compartmentCount = 3;
  static const height = 16.0;
  static const width = 100.0;
  static const radius = height / 2;

  const IntensityIndicator(this.intensity);

  IntensityIndicator.fromIrritant({required Irritant irritant, required Iterable<double> intensityThresholds})
      : intensity = IrritantService.intensity(dose: irritant.dosePerServing, intensityThresholds: intensityThresholds);

  /// An intensity indicator with no bars filled
  const IntensityIndicator.empty() : intensity = Intensity.none;

  @override
  Widget build(BuildContext context) {
    if (intensity == Intensity.unknown) return Container();

    final intensityCells = [Intensity.low, Intensity.medium, Intensity.high];

    final traceBox = _traceBox(width: width, color: GLColors.lightGold);
    final filledBoxes = List.generate(compartmentCount, (i) {
      final boxWidth = _boxWidth(i);
      final color = _fillColor(intensityCells, i);
      return _roundedBox(width: boxWidth, showBorder: true, color: color);
    }).reversed.toList();

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        if (intensity >= Intensity.trace) traceBox,
        ...filledBoxes,
        _roundedBox(width: width, showBorder: true),
      ],
    );
  }

  Color? _fillColor(List<Intensity> intensityCells, int i) {
    // If value is null, use 0
    if (intensity > intensityCells[i]) {
      switch (i) {
        case 0:
          return GLColors.lightGold;
        case 1:
          return GLColors.gold;
        default:
          return GLColors.darkGold;
      }
    } else {
      return null;
    }
  }

  double _boxWidth(int idxBox) {
    switch (idxBox) {
      case 0:
        return width * (idxBox + 1) / compartmentCount + 0.6 * radius; // the 0.6 just makes it look better ¯\_(ツ)_/¯
      case 1:
        return width * (idxBox + 1) / compartmentCount + 0.5 * radius;
      default:
        return width;
    }
  }

  Widget _traceBox({required double width, required Color color}) {
    final decoration = BoxDecoration(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(radius), bottomLeft: Radius.circular(radius)),
      // color: color,
      gradient: LinearGradient(colors: [color, color, GLColors.white]),
    );

    return ClipPath(
      clipper: TrapeziumClipper(),
      child: Container(
        decoration: decoration,
        width: width / 6,
        height: height,
      ),
    );
  }

  Widget _roundedBox({
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

class TrapeziumClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width * 2 / 3, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TrapeziumClipper oldClipper) => false;
}

// Modified from review_slider: https://github.com/kherel/reviews_slider

// MIT License
//
// Copyright (c) 2019 Kherel Kechil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:flutter/material.dart';

import '../../../util/math.dart' as math;
import '../models/severity.dart';
import '../style/gl_colors.dart';

class SeverityIndicator extends StatelessWidget {
  final double value;
  final double circleDiameter;
  final bool hasShadow;
  final Color headColor;
  final Color faceColor;
  final void Function(DragUpdateDetails)? onDrag;
  final void Function(DragEndDetails)? onDragEnd;
  final void Function(DragStartDetails)? onDragStart;

  static const defaultFaceColor = Color(0xFF616154);

  const SeverityIndicator._({
    required this.value,
    required this.circleDiameter,
    required this.hasShadow,
    required this.headColor,
    required this.faceColor,
    this.onDragStart,
    this.onDrag,
    this.onDragEnd,
  });

  factory SeverityIndicator.fromSeverity({
    required Severity severity,
    required double circleDiameter,
    void Function(DragStartDetails)? onDragStart,
    void Function(DragUpdateDetails)? onDrag,
    void Function(DragEndDetails)? onDragEnd,
  }) {
    return SeverityIndicator._(
      value: _severityToValue(severity),
      circleDiameter: circleDiameter,
      hasShadow: true,
      headColor: headColorFromSeverity(severity),
      faceColor: defaultFaceColor,
      onDragStart: onDragStart,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
    );
  }

  factory SeverityIndicator.fromValue({
    required double value,
    required double circleDiameter,
    void Function(DragStartDetails)? onDragStart,
    void Function(DragUpdateDetails)? onDrag,
    void Function(DragEndDetails)? onDragEnd,
  }) {
    return SeverityIndicator._(
      value: value,
      circleDiameter: circleDiameter,
      hasShadow: true,
      headColor: _headColorFromValue(value),
      faceColor: defaultFaceColor,
      onDragStart: onDragStart,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
    );
  }

  factory SeverityIndicator.grey({
    required double value,
    required double circleDiameter,
    void Function(DragStartDetails)? onDragStart,
    void Function(DragUpdateDetails)? onDrag,
    void Function(DragEndDetails)? onDragEnd,
  }) {
    return SeverityIndicator._(
      value: value,
      circleDiameter: circleDiameter,
      hasShadow: false,
      headColor: const Color(0xFFC9CED2),
      faceColor: Colors.white,
      onDragStart: onDragStart,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final faceValue = Severity.values.length - value - 1;

    return GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDrag,
      onHorizontalDragEnd: onDragEnd,
      child: SizedBox(
        width: circleDiameter,
        height: circleDiameter,
        child: Stack(
          children: <Widget>[
            _SeverityHead(color: headColor, hasShadow: hasShadow, circleDiameter: circleDiameter),
            _SeverityFace(color: faceColor, animationValue: faceValue, circleDiameter: circleDiameter)
          ],
        ),
      ),
    );
  }

  static double _severityToValue(Severity severity) {
    if (severity == Severity.mild) {
      return 0.0;
    } else if (severity == Severity.moderate) {
      return 1.0;
    } else if (severity == Severity.intense) {
      return 2.0;
    } else if (severity == Severity.severe) {
      return 3.0;
    } else {
      throw ArgumentError(severity);
    }
  }

  static Color headColorFromSeverity(Severity severity) {
    return _headColorFromValue(_severityToValue(severity));
  }

  static Color _headColorFromValue(double value) {
    final yellowOpacity = _yellowOpacity(value);
    const severe = GLColors.severeSeverity;
    const mild = GLColors.mildSeverity;
    final r = (mild.red * yellowOpacity + severe.red * (1 - yellowOpacity)).ceil();
    final g = (mild.green * yellowOpacity + severe.green * (1 - yellowOpacity)).ceil();
    final b = (mild.blue * yellowOpacity + severe.blue * (1 - yellowOpacity)).ceil();
    return Color.fromRGBO(r, g, b, 1.0);
  }

  static double _yellowOpacity(double value) {
    const redOnset = .7;
    final severityCount = Severity.values.length;
    return value < redOnset ? 1.0 : (severityCount - value) / (severityCount - redOnset);
  }
}

class _SeverityFace extends StatelessWidget {
  final double animationValue;
  final Color color;
  final double circleDiameter;

  const _SeverityFace({
    required this.color,
    required this.animationValue,
    required this.circleDiameter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: circleDiameter,
      width: circleDiameter,
      child: CustomPaint(
        size: const Size(300, 300),
        painter: _FacePainter(animationValue, color: color),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter(
    double animationValue, {
    this.color = const Color(0xFF615f56),
  })  : activeIndex = animationValue.floor(),
        unitAnimatingValue = (animationValue * 10 % 10 / 10);

  final int activeIndex;
  Color color;
  final double unitAnimatingValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawEye(canvas, size);
    _drawMouth(canvas, size);
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) {
    return unitAnimatingValue != oldDelegate.unitAnimatingValue || activeIndex != oldDelegate.activeIndex;
  }

  void _drawEye(Canvas canvas, Size size) {
    var angle = 0.0;
    var wide = 0.0;

    switch (activeIndex) {
      case 0:
        angle = 55 - unitAnimatingValue * 50;
        wide = 80.0;
        break;
      case 1:
        wide = 80 - unitAnimatingValue * 80;
        angle = 5;
        break;
    }
    final degree1 = 90 * 3 + angle;
    final degree2 = 90 * 3 - angle + wide;
    final x1 = size.width / 2 * 0.65;
    final x2 = size.width - x1;
    final y = size.height * 0.41;
    const eyeRadius = 5.0;

    final paint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(x1, y),
        radius: eyeRadius,
      ),
      math.radians(degree1),
      math.radians(360 - wide),
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(x2, y),
        radius: eyeRadius,
      ),
      math.radians(degree2),
      math.radians(360 - wide),
      false,
      paint,
    );
  }

  void _drawMouth(Canvas canvas, Size size) {
    final upperY = size.height * 0.70;
    final lowerY = size.height * 0.77;
    final middleY = (lowerY - upperY) / 2 + upperY;

    final leftX = size.width / 2 * 0.65;
    final rightX = size.width - leftX;
    final middleX = size.width / 2;

    var y1 = 0.0, y3 = 0.0, x2 = 0.0, y2 = 0.0;
    Path? path2;
    switch (activeIndex) {
      case 0:
        y1 = lowerY;
        x2 = middleX;
        y2 = upperY;
        y3 = lowerY;
        break;
      case 1:
        y1 = lowerY;
        x2 = middleX;
        y2 = unitAnimatingValue * (middleY - upperY) + upperY;
        y3 = lowerY - unitAnimatingValue * (lowerY - upperY);
        break;
      case 2:
        y1 = unitAnimatingValue * (upperY - lowerY) + lowerY;
        x2 = middleX;
        y2 = unitAnimatingValue * (lowerY + 3 - middleY) + middleY;
        y3 = upperY;
        break;
      case 3:
        y1 = upperY;
        x2 = middleX;
        y2 = lowerY + 3;
        y3 = upperY;
        path2 = Path()
          ..moveTo(leftX, y1)
          ..quadraticBezierTo(
            x2,
            y2,
            upperY - 2.5,
            y3 - 2.5,
          )
          ..quadraticBezierTo(
            x2,
            y2 - unitAnimatingValue * (y2 - upperY + 2.5),
            leftX,
            upperY - 2.5,
          )
          ..close();
        break;
      case 4:
        y1 = upperY;
        x2 = middleX;
        y2 = lowerY + 3;
        y3 = upperY;
        path2 = Path()
          ..moveTo(leftX, y1)
          ..quadraticBezierTo(
            x2,
            y2,
            upperY - 2.5,
            y3 - 2.5,
          )
          ..quadraticBezierTo(
            x2,
            upperY - 2.5,
            leftX,
            upperY - 2.5,
          )
          ..close();
        break;
    }
    final path = Path()
      ..moveTo(leftX, y1)
      ..quadraticBezierTo(
        x2,
        y2,
        rightX,
        y3,
      );

    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5);

    if (path2 != null) {
      canvas.drawPath(
        path2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

class _SeverityHead extends StatelessWidget {
  final Color color;
  final bool hasShadow;
  final double? circleDiameter;

  const _SeverityHead({required this.color, this.hasShadow = false, this.circleDiameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: circleDiameter,
      width: circleDiameter,
      decoration: BoxDecoration(
        boxShadow: hasShadow
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 5.0,
                )
              ]
            : null,
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

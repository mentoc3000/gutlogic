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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v_math;

import '../../../models/severity.dart';

typedef OnChange = void Function(Severity severity);

double _severityToValue(Severity severity) {
  switch (severity) {
    case Severity.mild:
      return 1;
    case Severity.moderate:
      return 2;
    case Severity.intense:
      return 3;
    case Severity.severe:
      return 4;
    default:
      throw ArgumentError(severity);
  }
}

Severity _valueToSeverity(int value) {
  switch (value) {
    case 1:
      return Severity.mild;
    case 2:
      return Severity.moderate;
    case 3:
      return Severity.intense;
    case 4:
      return Severity.severe;
    default:
      return Severity.mild;
  }
}

class SeveritySlider extends StatefulWidget {
  const SeveritySlider({
    Key? key,
    required this.onChange,
    this.initialSeverity = Severity.moderate,
    this.optionStyle,
    this.width,
    this.circleDiameter = 60,
  }) : super(key: key);

  /// The onChange callback calls every time when a pointer have changed
  /// the value of the slider and is no longer in contact with the screen.
  /// Callback function argument is an int number from 0 to 4, where
  /// 0 is the worst review value and 4 is the best review value

  /// ```dart
  /// ReviewSlider(
  ///  onChange: (int value){
  ///    print(value);
  ///  }),
  /// ),
  /// ```

  final OnChange onChange;
  final Severity initialSeverity;
  static const options = ['Mild', 'Moderate', 'Intense', 'Severe'];
  final TextStyle? optionStyle;
  final double? width;
  final double circleDiameter;
  @override
  _SeveritySliderState createState() => _SeveritySliderState();
}

class _SeveritySliderState extends State<SeveritySlider> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late double _animationValue;
  double _xOffset = 0.0;

  late AnimationController _controller;
  late Tween<double> _tween;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    final initValue = _severityToValue(widget.initialSeverity) - 1;
    _controller = AnimationController(
      value: initValue,
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _tween = Tween(end: initValue);
    _animation = _tween.animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _controller,
      ),
    )..addListener(() {
        setState(() {
          _animationValue = _animation.value;
        });
      });
    _animationValue = initValue;
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    widget.onChange(widget.initialSeverity);
  }

  void handleTap(int state) {
    _controller.duration = const Duration(milliseconds: 400);
    _tween.begin = _tween.end;
    _tween.end = state.toDouble();
    _controller.reset();
    _controller.forward();

    widget.onChange(_valueToSeverity(state + 1));
  }

  void _onDrag(double dx, innerWidth) {
    final newAnimatedValue = _calcAnimatedValueFormDragX(dx, innerWidth);

    if (newAnimatedValue > 0 && newAnimatedValue < SeveritySlider.options.length - 1) {
      setState(
        () {
          _animationValue = newAnimatedValue;
        },
      );
    }
  }

  void _onDragEnd(_) {
    _controller.duration = const Duration(milliseconds: 100);
    _tween.begin = _animationValue;
    _tween.end = _animationValue.round().toDouble();
    _controller.reset();
    _controller.forward();

    widget.onChange(_valueToSeverity(_animationValue.round()));
  }

  void _onDragStart(x, width) {
    final oneStepWidth = (width - widget.circleDiameter) / (SeveritySlider.options.length - 1);
    _xOffset = x - (oneStepWidth * _animationValue);
  }

  double _calcAnimatedValueFormDragX(double x, double innerWidth) {
    x = x - _xOffset;
    return x / (innerWidth - widget.circleDiameter) * (SeveritySlider.options.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: paddingSize),
      height: 100,
      child: LayoutBuilder(
        builder: (context, size) {
          final width = widget.width != null && widget.width! < size.maxWidth ? widget.width! : size.maxWidth;
          return Stack(
            children: <Widget>[
              MeasureLine(
                states: SeveritySlider.options,
                handleTap: handleTap,
                animationValue: _animationValue,
                width: width,
                optionStyle: widget.optionStyle,
                circleDiameter: widget.circleDiameter,
              ),
              MyIndicator(
                circleDiameter: widget.circleDiameter,
                animationValue: _animationValue,
                width: width,
                onDragStart: (details) {
                  _onDragStart(details.globalPosition.dx, width);
                },
                onDrag: (details) {
                  _onDrag(details.globalPosition.dx, width);
                },
                onDragEnd: _onDragEnd,
              ),
            ],
          );
        },
      ),
    );
  }
}

//const double circleDiameter = 30;
const double paddingSize = 10;

class MeasureLine extends StatelessWidget {
  MeasureLine({
    required this.handleTap,
    required this.animationValue,
    required this.states,
    required this.width,
    required this.optionStyle,
    required this.circleDiameter,
  });

  final double animationValue;
  final Function handleTap;
  final List<String> states;
  final double width;
  final TextStyle? optionStyle;
  final double circleDiameter;
  List<Widget> _buildUnits() {
    final res = <Widget>[];
    final animatingUnitIndex = animationValue.round();
    final unitAnimatingValue = (animationValue * 10 % 10 / 10 - 0.5).abs() * 2;

    states.asMap().forEach((index, text) {
      var paddingTop = 0.0;
      var scale = 0.7;
      var opacity = .3;
      if (animatingUnitIndex == index) {
        paddingTop = unitAnimatingValue * 5;
        scale = (1 - unitAnimatingValue) * 0.7;
        opacity = 0.3 + unitAnimatingValue * 0.7;
      }
      final faceValue = (states.length - index - 1).toDouble();
      res.add(Expanded(
        key: ValueKey(text),
        child: GestureDetector(
          onTap: () {
            handleTap(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Transform.scale(
                  scale: scale,
                  child: Stack(
                    children: [
                      Head(
                        circleDiameter: circleDiameter,
                      ),
                      Face(
                        circleDiameter: circleDiameter,
                        color: Colors.white,
                        animationValue: faceValue,
                      )
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(top: paddingTop),
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    text,
                    style: optionStyle ?? const TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: circleDiameter / 2,
            left: width / 8,
            width: width * 3 / 4,
            child: Container(
              width: width,
              color: const Color(0xFFeceeef),
              height: 3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildUnits(),
          ),
        ],
      ),
    );
  }
}

class Face extends StatelessWidget {
  Face({this.color = const Color(0xFF616154), required this.animationValue, required this.circleDiameter});

  final double animationValue;
  final Color color;
  final double circleDiameter;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: circleDiameter,
      width: circleDiameter,
      child: CustomPaint(
        size: const Size(300, 300),
        painter: MyPainter(animationValue, color: color),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(
    animationValue, {
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
  bool shouldRepaint(MyPainter oldDelegate) {
    return unitAnimatingValue != oldDelegate.unitAnimatingValue || activeIndex != oldDelegate.activeIndex;
  }

  void _drawEye(canvas, size) {
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
      v_math.radians(degree1),
      v_math.radians(360 - wide),
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(x2, y),
        radius: eyeRadius,
      ),
      v_math.radians(degree2),
      v_math.radians(360 - wide),
      false,
      paint,
    );
  }

  void _drawMouth(Canvas canvas, size) {
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

class MyIndicator extends StatelessWidget {
  MyIndicator({
    required this.animationValue,
    required this.width,
    required this.onDrag,
    required this.onDragStart,
    required this.onDragEnd,
    required this.circleDiameter,
  }) : position = (animationValue + .5) / 4;

  final double animationValue;
  final Function onDrag;
  final Function onDragEnd;
  final Function onDragStart;
  final double position;
  final double width;
  final double circleDiameter;

  Widget _buildIndicator() {
    const redOnset = .3;
    final opacityOfYellow = position < redOnset ? 1.0 : (1 - position) / (1 - redOnset);
    final faceValue = SeveritySlider.options.length - animationValue - 1;
    return GestureDetector(
      onHorizontalDragStart: (_) => onDragStart,
      onHorizontalDragUpdate: (_) => onDrag,
      onHorizontalDragEnd: (_) => onDragEnd,
      child: Container(
        width: circleDiameter,
        height: circleDiameter,
        child: Stack(
          children: <Widget>[
            Head(
              color: const Color(0xFFE13D5E), // angry face color
              hasShadow: true,
            ),
            Opacity(
              opacity: opacityOfYellow,
              child: Head(
                color: const Color(0xFFfee385), // happy face color
              ),
            ),
            Face(
              animationValue: faceValue,
              circleDiameter: circleDiameter,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Positioned(
        top: 0,
        left: width * position - circleDiameter / 2,
        child: _buildIndicator(),
      ),
    );
  }
}

class Head extends StatelessWidget {
  Head({this.color = const Color(0xFFc9ced2), this.hasShadow = false, this.circleDiameter});

  final Color color;
  final bool hasShadow;
  final double? circleDiameter;
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

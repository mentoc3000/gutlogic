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

import '../../../models/severity.dart';
import '../../../widgets/severity_indicator.dart';

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
  State<SeveritySlider> createState() => _SeveritySliderState();
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
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
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

  void _onDrag(double dx, double innerWidth) {
    final newAnimatedValue = _calcAnimatedValueFormDragX(dx, innerWidth);

    if (newAnimatedValue > 0 && newAnimatedValue < SeveritySlider.options.length - 1) {
      setState(
        () {
          _animationValue = newAnimatedValue;
        },
      );
    }
  }

  void _onDragEnd(DragEndDetails _) {
    _controller.duration = const Duration(milliseconds: 100);
    _tween.begin = _animationValue;
    _tween.end = _animationValue.round().toDouble();
    _controller.reset();
    _controller.forward();

    widget.onChange(_valueToSeverity(_animationValue.round()));
  }

  void _onDragStart(double x, double width) {
    final oneStepWidth = (width - widget.circleDiameter) / (SeveritySlider.options.length - 1);
    _xOffset = x - (oneStepWidth * _animationValue);
  }

  double _calcAnimatedValueFormDragX(double x, double innerWidth) {
    x = x - _xOffset;
    return x / (innerWidth - widget.circleDiameter) * (SeveritySlider.options.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final position = (_animationValue + 0.5) / 4;
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
              Positioned(
                top: 0,
                left: width * position - widget.circleDiameter / 2,
                child: SeverityIndicator.fromValue(
                  value: _animationValue,
                  circleDiameter: widget.circleDiameter,
                  onDragStart: (DragStartDetails details) => _onDragStart(details.globalPosition.dx, width),
                  onDrag: (DragUpdateDetails details) => _onDrag(details.globalPosition.dx, width),
                  onDragEnd: _onDragEnd,
                ),
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
  const MeasureLine({
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
                child: SeverityIndicator.grey(value: faceValue, circleDiameter: circleDiameter),
              ),
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
    return Stack(
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
    );
  }
}

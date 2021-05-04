import 'package:flutter/material.dart';

class GLSlider extends StatefulWidget {
  final int min;
  final int max;
  final int value;
  final void Function(int) onChanged;
  final void Function(int) onChangeEnd;

  const GLSlider({
    Key? key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  }) : super(key: key);

  @override
  _GLSliderState createState() => _GLSliderState(min: min, max: max, value: value);
}

class _GLSliderState extends State<GLSlider> {
  final int divisions;

  int value;

  _GLSliderState({required int min, required int max, required this.value}) : divisions = max - min;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: widget.min.toDouble(),
      max: widget.max.toDouble(),
      value: value.toDouble(),
      label: '$value',
      divisions: divisions,
      onChanged: (double x) {
        setState(() {
          value = x.toInt();
        });
        widget.onChanged(x.toInt());
      },
      onChangeEnd: (double x) => widget.onChangeEnd(x.floor()),
    );
  }
}

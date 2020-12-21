import 'package:flutter/material.dart';

class GLSlider extends StatefulWidget {
  final int min;
  final int max;
  final int value;
  final void Function(int) onChanged;
  final void Function(int) onChangeEnd;

  const GLSlider({
    Key key,
    this.min = 0,
    this.max,
    this.value,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  _GLSliderState createState() => _GLSliderState();
}

class _GLSliderState extends State<GLSlider> {
  int value;
  int divisions;

  @override
  void initState() {
    super.initState();
    value = widget.value ?? widget.min;
    divisions = widget.max - widget.min;
  }

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

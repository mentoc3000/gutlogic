import 'package:flutter/material.dart';

class SliderTile extends StatefulWidget {
  final int minimum;
  final int maximum;
  final int initial;

  const SliderTile({this.minimum = 0, this.maximum = 10, this.initial = 5});

  @override
  State<SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<SliderTile> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Slider(
            min: widget.minimum.toDouble(),
            max: widget.maximum.toDouble(),
            value: value.toDouble(),
            divisions: widget.maximum - widget.minimum,
            onChanged: (newValue) => setState(() => value = newValue.toInt()),
          ),
        )
      ],
    );
  }
}

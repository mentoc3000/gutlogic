import 'package:flutter/material.dart';

class SliderTile extends StatefulWidget {

  final int minimum;
  final int maximum;
  final int initial;

  SliderTile({this.minimum: 0, this.maximum: 10, this.initial: 5});

  @override
  _SliderTileState createState() => _SliderTileState();
}

class _SliderTileState extends State<SliderTile> {

  int value;

  @override
  void initState() {
    super.initState();
    this.value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Slider(
              min: widget.minimum.toDouble(),
              max: widget.maximum.toDouble(),
              value: value.toDouble(),
              divisions: widget.maximum - widget.minimum,
              onChanged: (newValue) => setState(() => value=newValue.toInt()),
            )
          )
        ],
      ),
    );
  }
}
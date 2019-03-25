import 'package:flutter/material.dart';

class SliderTile extends StatefulWidget {

  final double minimum;
  final double maximum;
  final double initial;

  SliderTile({this.minimum: 0.0, this.maximum: 10.0, this.initial: 5.0});

  @override
  _SliderTileState createState() => _SliderTileState();
}

class _SliderTileState extends State<SliderTile> {

  double value;

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
              min: widget.minimum,
              max: widget.maximum,
              value: value,
              onChanged: (newValue) => setState(() => value=newValue),
            )
          )
        ],
      ),
    );
  }
}
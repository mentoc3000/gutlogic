import 'package:flutter/material.dart';



class BMTypeSliderTile extends StatefulWidget {

  final int minimum = 0;
  final int maximum = 8;
  final int type;

  BMTypeSliderTile({this.type: 5});

  @override
  _BMTypeSliderTileState createState() => _BMTypeSliderTileState();
}

class _BMTypeSliderTileState extends State<BMTypeSliderTile> {

  int value;

  @override
  void initState() {
    super.initState();
    this.value = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Slider(
            min: widget.minimum.toDouble(),
            max: widget.maximum.toDouble(),
            value: value.toDouble(),
            divisions: widget.maximum - widget.minimum,
            onChanged: (newValue) => setState(() => value=newValue.toInt()),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';



class BMTypeSliderTile extends StatefulWidget {

  final int minimum = 1;
  final int maximum = 8;
  final int type;
  final List<String> descriptions = [
    'Type 1',
    'Type 2',
    'Type 3',
    'Type 4',
    'Type 5',
    'Type 6',
    'Type 7',
    'Type 8',
  ];

  BMTypeSliderTile({this.type: 5});

  @override
  _BMTypeSliderTileState createState() => _BMTypeSliderTileState();
}

class _BMTypeSliderTileState extends State<BMTypeSliderTile> {

  int value;
  String description;

  @override
  void initState() {
    super.initState();
    this.value = widget.type;
    this.description = widget.descriptions[widget.type - 1];
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
            onChanged: (newValue) => setState(() {
              value=newValue.toInt();
              description=widget.descriptions[value - 1];
            }),
          ),
          Text(description)
        ],
      ),
    );
  }
}
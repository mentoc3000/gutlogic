import 'package:flutter/material.dart';



class BMVolumeSliderTile extends StatefulWidget {

  final int minimum = 1;
  final int maximum = 5;
  final int volume;
  final List<String> descriptions = [
    'Low Volume',
    'Moderately Low Volume',
    'Moderate Volume',
    'Moderately High Volume',
    'High Volume',
  ];

  BMVolumeSliderTile({this.volume: 3});

  @override
  _BMVolumeSliderTileState createState() => _BMVolumeSliderTileState();
}

class _BMVolumeSliderTileState extends State<BMVolumeSliderTile> {

  int value;
  String description;

  @override
  void initState() {
    super.initState();
    this.value = widget.volume;
    this.description = widget.descriptions[widget.volume - 1];
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
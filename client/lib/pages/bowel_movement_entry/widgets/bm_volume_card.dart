import 'package:flutter/widgets.dart';
import '../../../widgets/cards/headed_card.dart';
import '../../../widgets/gl_slider.dart';

class BMVolumeCard extends StatefulWidget {
  final int minimum = 1;
  final int maximum = 5;
  final int volume;
  final void Function(int) onChanged;

  BMVolumeCard({this.volume, this.onChanged});

  @override
  _BMVolumeCardState createState() => _BMVolumeCardState();
}

class _BMVolumeCardState extends State<BMVolumeCard> {
  int value;
  String description;
  final List<String> descriptions = [
    'Low Volume',
    'Moderately Low Volume',
    'Moderate Volume',
    'Moderately High Volume',
    'High Volume',
  ];

  @override
  void initState() {
    super.initState();
    value = widget.volume;
    description = descriptions[widget.volume - 1];
  }

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Volume',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GLSlider(
            min: widget.minimum,
            max: widget.maximum,
            value: value,
            onChanged: (int newValue) {
              setState(() {
                description = descriptions[newValue - 1];
              });
            },
            onChangeEnd: widget.onChanged,
          ),
          Text(description)
        ],
      ),
    );
  }
}

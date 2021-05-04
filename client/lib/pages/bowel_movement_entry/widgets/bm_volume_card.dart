import 'package:flutter/widgets.dart';

import '../../../widgets/cards/headed_card.dart';
import '../../../widgets/gl_slider.dart';

class BMVolumeCard extends StatefulWidget {
  final int minimum = 1;
  final int maximum = 5;
  final int volume;
  final void Function(int)? onChanged;

  BMVolumeCard({required this.volume, this.onChanged});

  @override
  _BMVolumeCardState createState() => _BMVolumeCardState(value: volume);
}

class _BMVolumeCardState extends State<BMVolumeCard> {
  static const List<String> descriptions = [
    'Low Volume',
    'Moderately Low Volume',
    'Moderate Volume',
    'Moderately High Volume',
    'High Volume',
  ];

  int value;

  _BMVolumeCardState({required this.value});

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
            onChanged: (int value) {
              setState(() {
                this.value = value;
              });
            },
            onChangeEnd: (int value) {
              widget.onChanged?.call(value);
            },
          ),
          Text(descriptions[value - 1])
        ],
      ),
    );
  }
}

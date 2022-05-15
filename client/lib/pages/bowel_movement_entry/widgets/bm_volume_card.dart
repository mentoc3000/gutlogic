import 'package:flutter/widgets.dart';

import '../../../widgets/cards/headed_card.dart';
import '../../../widgets/gl_slider.dart';

class BMVolumeCard extends StatefulWidget {
  final int minimum = 1;
  final int maximum = 5;
  final int volume;
  final void Function(int)? onChanged;

  const BMVolumeCard({required this.volume, this.onChanged});

  @override
  State<BMVolumeCard> createState() => _BMVolumeCardState();
}

class _BMVolumeCardState extends State<BMVolumeCard> {
  static const List<String> descriptions = [
    'Low Volume',
    'Moderately Low Volume',
    'Moderate Volume',
    'Moderately High Volume',
    'High Volume',
  ];

  late int value;

  _BMVolumeCardState();

  @override
  void initState() {
    super.initState();
    value = widget.volume;
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

import 'package:flutter/widgets.dart';

import '../../../widgets/cards/headed_card.dart';
import '../../../widgets/gl_slider.dart';

class BMTypeCard extends StatefulWidget {
  final int minimum = 1;
  final int maximum = 7;
  final int type;
  final void Function(int)? onChanged;

  BMTypeCard({required this.type, this.onChanged});

  @override
  _BMTypeCardState createState() => _BMTypeCardState(value: type);
}

class _BMTypeCardState extends State<BMTypeCard> {
  static const List<String> descriptions = [
    'Separate, hard lumps',
    'Lumpy and sausage-like',
    'Sausage shape with cracks',
    'Smooth, soft sausage shape',
    'Soft blobs with clear-cut edges',
    'Fluffy pieces with ragged edges, mushy',
    'Watery, no solid pieces',
  ];

  int value;

  _BMTypeCardState({required this.value});

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Type',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GLSlider(
            min: widget.minimum,
            max: widget.maximum,
            value: value,
            onChanged: (int value) => setState(() {
              this.value = value;
            }),
            onChangeEnd: (value) {
              widget.onChanged?.call(value);
            },
          ),
          Text(descriptions[value - 1])
        ],
      ),
    );
  }
}

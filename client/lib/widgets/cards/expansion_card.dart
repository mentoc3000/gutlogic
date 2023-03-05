import 'package:flutter/material.dart';

import '../../style/gl_text_style.dart';
import 'gl_card.dart';

class ExpansionCard extends StatelessWidget {
  final String heading;
  final List<Widget> items;
  final bool initiallyExpanded;

  const ExpansionCard({Key? key, required this.heading, required this.items, this.initiallyExpanded = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: GLCard(
        child: ExpansionTile(
          title: Text(heading, style: tileHeadingStyle),
          initiallyExpanded: initiallyExpanded,
          children: items,
        ),
      ),
    );
  }
}

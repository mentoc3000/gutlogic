import 'package:flutter/material.dart';

import '../../style/gl_theme.dart';
import 'gl_card.dart';

class ExpansionCard extends StatelessWidget {
  final String heading;
  final List<Widget> items;

  const ExpansionCard({Key? key, required this.heading, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: GLCard(
        child: ExpansionTile(
          title: Text(heading, style: tileHeadingTheme),
          children: items,
        ),
      ),
    );
  }
}

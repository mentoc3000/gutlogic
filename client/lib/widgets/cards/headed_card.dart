import 'package:flutter/widgets.dart';

import '../list_tiles/header_list_tile.dart';
import 'gl_card.dart';

class HeadedCard extends StatelessWidget {
  final String heading;
  final Widget content;
  final Widget? trailing;

  const HeadedCard({Key? key, required this.heading, required this.content, this.trailing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Column(
        children: [
          HeaderListTile(heading: heading, trailing: trailing),
          content,
        ],
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import '../list_tiles/header_list_tile.dart';
import 'gl_card.dart';

class HeadedCard extends StatelessWidget {
  final String heading;
  final Widget content;

  const HeadedCard({Key key, this.heading, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Column(
        children: [
          if (heading != null) HeaderListTile(heading: heading),
          if (content != null) content,
        ],
      ),
    );
  }
}

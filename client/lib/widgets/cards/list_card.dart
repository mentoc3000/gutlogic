import 'package:flutter/widgets.dart';
import '../list_tiles/header_list_tile.dart';
import 'gl_card.dart';

class ListCard extends StatelessWidget {
  final String heading;
  final List<Widget> items;

  const ListCard({Key key, this.heading, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Column(
        children: [
          if (heading != null) HeaderListTile(heading: heading),
          if (items != null) ...items,
        ],
      ),
    );
  }
}

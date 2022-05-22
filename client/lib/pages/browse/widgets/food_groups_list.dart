import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import '../../../routes/routes.dart';
import '../../../widgets/list_tiles/push_list_tile.dart';

class FoodGroupsList extends StatelessWidget {
  final BuiltSet<String> groups;
  const FoodGroupsList({Key? key, required this.groups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedGroups = groups.toList()..sort();
    final tiles = sortedGroups.map((name) {
      return PushListTile(
        heading: name,
        onTap: () => Navigator.of(context).push(Routes.of(context).createFoodGroupRoute(name: name)),
      );
    }).toList();
    return ListView(children: tiles);
  }
}

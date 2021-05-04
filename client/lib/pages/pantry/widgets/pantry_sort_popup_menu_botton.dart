import 'package:flutter/widgets.dart';

import '../../../models/pantry/pantry_sort.dart';
import '../../../widgets/gl_icons.dart';
import '../../../widgets/popup_menu_button/gl_popup_menu_button.dart';
import '../../../widgets/popup_menu_button/gl_popup_menu_item.dart';

class PantrySortPopupMenuButton extends StatelessWidget {
  final void Function(PantrySort) onSelected;

  const PantrySortPopupMenuButton({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const items = [
      GLPopupMenuItem(value: PantrySort.alphabeticalAscending, child: Text('A to Z')),
      GLPopupMenuItem(value: PantrySort.sensitivityAscending, child: Text('Low to High')),
      GLPopupMenuItem(value: PantrySort.sensitivityDescending, child: Text('High to Low')),
    ];

    return GLPopupMenuButton(
      icon: const Icon(GLIcons.sort),
      items: items,
      onSelected: onSelected,
    );
  }
}

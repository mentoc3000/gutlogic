import 'package:flutter/widgets.dart';

import '../../../models/diary_entry/bowel_movement_entry.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import 'diary_entry_list_tile.dart';

class BowelMovementEntryListTile extends StatelessWidget {
  final BowelMovementEntry entry;

  const BowelMovementEntryListTile({@required this.entry});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Bowel Movement',
      diaryEntry: entry,
      barColor: GLColors.bowelMovement,
      onTap: () => Navigator.push(context, Routes.of(context).createBowelMovementEntryRoute(entry: entry)),
    );
  }
}

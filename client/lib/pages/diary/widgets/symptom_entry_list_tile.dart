import 'package:flutter/widgets.dart';

import '../../../models/diary_entry/symptom_entry.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import 'diary_entry_list_tile.dart';

class SymptomEntryListTile extends StatelessWidget {
  final SymptomEntry entry;

  const SymptomEntryListTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final symptomName = entry.symptom.symptomType.name == '' ? 'Symptom' : entry.symptom.symptomType.name;
    return DiaryEntryListTile(
      heading: symptomName,
      // subheadings: ['Severity: ' + entry.symptom.severity.toString()],
      diaryEntry: entry,
      barColor: GLColors.symptom,
      onTap: () => Navigator.push(context, Routes.of(context).createSymptomEntryRoute(entry: entry)),
    );
  }
}

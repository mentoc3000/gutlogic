import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/diary/diary.dart';
import '../../../models/diary_entry/diary_entry.dart';
import '../../../style/gl_text_style.dart';
import '../../../widgets/alert_dialogs/confirm_delete_dialog.dart';
import '../../../widgets/dismissible/delete_dismissible.dart';
import '../../../widgets/gl_icons.dart';

class DiaryEntryListTile extends StatelessWidget {
  final String heading;
  final Iterable<String> subheadings;
  final DiaryEntry diaryEntry;
  final Color barColor;
  final VoidCallback? onTap;
  final Widget? leading;

  const DiaryEntryListTile({
    required this.heading,
    this.subheadings = const <String>[],
    required this.diaryEntry,
    required this.barColor,
    this.onTap,
    this.leading,
  });

  Widget buildTime(BuildContext context) {
    final dateFormatter = MediaQuery.of(context).alwaysUse24HourFormat ? DateFormat.Hm() : DateFormat.jm();
    final topInset = subheadings.any((s) => s.isNotEmpty) ? 1.0 : 6.0;
    final scale = MediaQuery.textScaleFactorOf(context);
    const defaultWidth = 65;

    return Container(
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        width: defaultWidth * scale,
        child: Text(
          key: const Key('diary_entry_time'),
          dateFormatter.format(diaryEntry.datetime.toLocal()),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget buildHeading() {
    final paddedLeading = leading != null ? Padding(padding: const EdgeInsets.only(right: 8), child: leading!) : null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (paddedLeading != null) paddedLeading,
        Text(heading, style: tileHeadingStyle),
      ],
    );
  }

  Widget buildSubheading() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subheadings
            .map((s) => Container(
                  padding: const EdgeInsets.all(6),
                  child: Text(s, style: tileSubheadingStyle),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCenter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 5, 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 3.0, color: barColor),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeading(),
          if (subheadings.isNotEmpty) buildSubheading(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaryEntriesBloc = BlocProvider.of<DiaryBloc>(context);
    return DeleteDismissible(
      child: ListTile(
        dense: true,
        leading: buildTime(context),
        title: buildCenter(),
        trailing: const Icon(GLIcons.arrowRight),
        onTap: onTap,
      ),
      onDelete: () => diaryEntriesBloc.add(Delete(diaryEntry)),
      confirmDismiss: (_) => showDialog(
        context: context,
        builder: (_) => const ConfirmDeleteDialog(itemName: 'entry'),
      ),
    );
  }
}

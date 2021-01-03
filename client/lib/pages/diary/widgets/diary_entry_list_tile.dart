import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/diary/diary.dart';
import '../../../models/diary_entry/diary_entry.dart';
import '../../../style/gl_theme.dart';
import '../../../widgets/alert_dialogs/confirm_delete_dialog.dart';
import '../../../widgets/dismissible/delete_dismissible.dart';
import '../../../widgets/gl_icons.dart';

class DiaryEntryListTile extends StatelessWidget {
  final String heading;
  final Iterable<String> subheadings;
  final DiaryEntry diaryEntry;
  final Color barColor;
  final void Function() onTap;

  bool get hasSubheadings => subheadings?.fold(false, (prev, element) => prev || element.isNotEmpty) ?? false;

  const DiaryEntryListTile({
    this.heading,
    this.subheadings,
    this.diaryEntry,
    this.barColor,
    this.onTap,
  });

  Widget buildTime(BuildContext context) {
    final dateFormatter = DateFormat.jm();
    final topInset = hasSubheadings ? 1.0 : 6.0;
    final scale = MediaQuery.textScaleFactorOf(context);
    const defaultWidth = 65;

    return Container(
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        width: defaultWidth * scale,
        child: Text(
          dateFormatter.format(diaryEntry.datetime.toLocal()),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget buildHeading() {
    return Text(
      heading,
      style: tileHeadingTheme,
    );
  }

  Widget buildSubheading() {
    if (subheadings.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subheadings
            .map((s) => Container(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    s,
                    style: tileSubheadingTheme,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCenter() {
    List<Widget> children;
    if (subheadings == null) {
      children = [
        buildHeading(),
      ];
    } else {
      children = [
        buildHeading(),
        buildSubheading(),
      ];
    }

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
        children: children,
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
      confirmDismiss: () => showDialog(
        context: context,
        builder: (_) => const ConfirmDeleteDialog(itemName: 'entry'),
      ),
    );
  }
}

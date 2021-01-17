import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../../style/gl_colors.dart';
import '../../../style/gl_theme.dart';

class DateTile extends StatelessWidget {
  final DateTime datetime;

  const DateTile({this.datetime});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat.MMMEd();

    return Container(
      color: GLColors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
        decoration: BoxDecoration(
          color: GLColors.lighterGray,
          borderRadius: const BorderRadius.all(Radius.circular(1E10)), // Always use semicircle ends
        ),
        child: Text(
          dateFormatter.format(datetime),
          style: tileHeadingTheme,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../gl_icons.dart';
import 'gl_card.dart';

class DateTimeCard extends StatelessWidget {
  final DateTime dateTime;
  final void Function(DateTime?) onChanged;

  const DateTimeCard({required this.dateTime, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat("EEE, MMM d, yyy  'at' ");
    final dateTimeFormatter =
        MediaQuery.of(context).alwaysUse24HourFormat ? dateFormatter.add_Hm() : dateFormatter.add_jm();
    final dateTimeDisplay = dateTimeFormatter.format(dateTime.toLocal());
    final controller = TextEditingController(text: dateTimeDisplay);
    return GLCard(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: TextField(
          readOnly: true,
          controller: controller,
          textAlignVertical: TextAlignVertical.bottom,
          decoration: const InputDecoration(
            suffixIcon: Icon(GLIcons.calendar),
          ),
          onTap: () => onTap(context),
        ),
      ),
    );
  }

  void onTap(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: onChanged,
      currentTime: dateTime.toLocal(),
    );
  }
}

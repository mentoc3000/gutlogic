import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'gl_card.dart';

class DateTimeCard extends StatelessWidget {
  final DateTime dateTime;
  final void Function(DateTime?) onChanged;

  const DateTimeCard({required this.dateTime, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: DateTimeField(
          initialValue: dateTime.toLocal(),
          format: DateFormat("EEE, MMM d, yyyy 'at' h:mma"),
          onShowPicker: (BuildContext context, DateTime? currentValue) async {
            // Show date and time in local timezone
            currentValue = currentValue!.toLocal();
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue,
              lastDate: DateTime(2100),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(currentValue),
              );
              return DateTimeField.combine(date, time);
            } else {
              return currentValue;
            }
          },
          readOnly: true,
          resetIcon: null,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

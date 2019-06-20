import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'gutai_card.dart';

class DatetimeView extends StatelessWidget {
  final DateTime date;
  final void Function(DateTime) onChanged;

  DatetimeView({this.date, this.onChanged});

  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  final InputType inputType = InputType.both;
  final bool editable = false;

  @override
  Widget build(BuildContext context) {
    return GutAICard(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: DateTimePickerFormField(
          initialValue: date,
          inputType: inputType,
          format: formats[inputType],
          editable: editable,
          decoration: InputDecoration(
            labelText: 'Date/Time',
            hasFloatingPlaceholder: false,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

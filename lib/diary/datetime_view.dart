import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class DatetimeView extends StatefulWidget {
  @override
  _DatetimeViewState createState() => _DatetimeViewState();
}

class _DatetimeViewState extends State<DatetimeView> {
  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;

  @override
  Widget build(BuildContext context) {
    return DateTimePickerFormField(
      inputType: inputType,
      format: formats[inputType],
      editable: editable,
      decoration: InputDecoration(
          labelText: 'Date/Time', hasFloatingPlaceholder: false),
      onChanged: (dt) => setState(() => date = dt),
    );
  }

  void updateInputType({bool date, bool time}) {
    date = date ?? inputType != InputType.time;
    time = time ?? inputType != InputType.date;
    setState(() => inputType =
        date ? time ? InputType.both : InputType.date : InputType.time);
  }
}
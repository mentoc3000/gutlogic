import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/placeholder_widget.dart';
import '../widgets/datetime_view.dart';

class SymptomEntryPage extends StatefulWidget {
  static String tag = 'symptom-entry-page';

  final SymptomEntry entry;

  SymptomEntryPage({this.entry});

  @override
  SymptomEntryPageState createState() => SymptomEntryPageState();
}

class SymptomEntryPageState extends State<SymptomEntryPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      DatetimeView(
        date: widget.entry.dateTime,
      ),
    ];

    return Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.red),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Symptom'),
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) =>
              Padding(padding: EdgeInsets.all(1.0), child: items[index]),
          padding: EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'placeholder_widget.dart';

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Symptom'),
      ),
      body: PlaceholderWidget(Colors.yellowAccent)
    );
  }
}

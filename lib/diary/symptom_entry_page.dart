import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/helpers/placeholder_widget.dart';

class SymptomEntryPage extends StatefulWidget {
  static String tag = 'food-entry-page';

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
        title: Text('Bowel Movement'),
      ),
      body: PlaceholderWidget(Colors.yellowAccent)
    );
  }
}

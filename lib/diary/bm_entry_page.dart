import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/helpers/placeholder_widget.dart';

class BMEntryPage extends StatefulWidget {
  static String tag = 'bm-entry-page';

  final BowelMovementEntry entry;

  BMEntryPage({this.entry});

  @override
  BMEntryPageState createState() => BMEntryPageState();
}

class BMEntryPageState extends State<BMEntryPage> {

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

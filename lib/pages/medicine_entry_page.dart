import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/placeholder_widget.dart';

class DosesEntryPage extends StatefulWidget {
  static String tag = 'medicine-entry-page';

  final DosesEntry entry;

  DosesEntryPage({this.entry});

  @override
  DosesEntryPageState createState() => DosesEntryPageState();
}

class DosesEntryPageState extends State<DosesEntryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Medicine'),
      ),
      body: PlaceholderWidget(Colors.redAccent)
    );
  }
}

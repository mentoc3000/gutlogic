import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/helpers/placeholder_widget.dart';

class MedicineEntryPage extends StatefulWidget {
  static String tag = 'food-entry-page';

  final MedicineEntry entry;

  MedicineEntryPage({this.entry});

  @override
  MedicineEntryPageState createState() => MedicineEntryPageState();
}

class MedicineEntryPageState extends State<MedicineEntryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.entry.medicine.name),
      ),
      body: PlaceholderWidget(Colors.redAccent)
    );
  }
}

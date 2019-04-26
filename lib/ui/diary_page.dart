import 'package:flutter/material.dart';
import 'diary_tiles.dart';
import 'entry_header.dart';
import 'package:gut_ai/models/sensitivity.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/resources/dummy_data.dart';
import '../blocs/diary_entry_bloc.dart';

class DiaryPage extends StatefulWidget {
  static String tag = 'diary-page';
  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {

  final _diaryEntryBloc = DiaryEntryBloc();
  List<DiaryEntry> entries;

  @override
  void initState() {
    super.initState();
    entries = _diaryEntryBloc.fetchAllDiaryEntries();
  }

  Widget buildEntryTile(DiaryEntry entry) {
    switch (entry.runtimeType) {
      case MealEntry:
        return MealEntryListTile(
          entry: entry,
          onUpdate: (e) => setState(() => entry = e),
        );
      case BowelMovementEntry:
        return BowelMovementEntryListTile(entry: entry,);
      case MedicineEntry:
        return MedicineEntryListTile(entry: entry,);
      case SymptomEntry:
        return SymptomEntryListTile(entry: entry,);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: entries.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(1.0),
          child: buildEntryTile(entries[index]),
        ),
        padding: EdgeInsets.all(0.0),
      ),
    );
  }
}

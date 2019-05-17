import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../widgets/diary_tiles.dart';
import 'meal_entry_page.dart';
import '../models/diary_entry.dart';
import '../blocs/diary_entry_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class DiaryPage extends StatefulWidget {
  static String tag = 'diary-page';
  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {
  final _diaryEntryBloc = DiaryEntryBloc();

  @override
  void dispose() {
    super.dispose();
    _diaryEntryBloc.dispose();
  }

  Widget buildEntryTile(DiaryEntry entry) {
    switch (entry.runtimeType) {
      case MealEntry:
        return MealEntryListTile(
          entry: entry,
          onUpdate: (e) => setState(() => entry = e),
        );
      case BowelMovementEntry:
        return BowelMovementEntryListTile(
          entry: entry,
        );
      case DosesEntry:
        return DosesEntryListTile(
          entry: entry,
        );
      case SymptomEntry:
        return SymptomEntryListTile(
          entry: entry,
          onSaved: (e) => setState(() => entry = e),
        );
      default:
        return null;
    }
  }

  List<Widget> entriesToTiles(List<DiaryEntry> entries) {

    if (entries == []) {
      return [];
    }

    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    var dateFormatter = DateFormat.yMd();

    List<Widget> tiles = [];
    for (var i = 0; i < entries.length; i++) {
      if (i == 0 || dateFormatter.format(entries[i].dateTime) != dateFormatter.format(entries[i-1].dateTime)) {
        tiles.add(DateTile(dateTime: entries[i].dateTime));
      }
      tiles.add(buildEntryTile(entries[i]));
    }

    return tiles;

  }

  @override
  Widget build(BuildContext context) {
    _diaryEntryBloc.fetchAllDiaryEntries();

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Diary"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              // child: Container(
              //   decoration: BoxDecoration(border: Border.all()),
                child: StreamBuilder(
                  stream: _diaryEntryBloc.allFoods,
                  builder: (context, AsyncSnapshot<List<DiaryEntry>> snapshot) {
                    if (!snapshot.hasData) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: CircularProgressIndicator()),
                          ],);
                    } else {
                      List<Widget> tiles = entriesToTiles(snapshot.data);
                      return ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: tiles.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.all(0.0),
                              child: tiles[index],
                            ),
                        padding: EdgeInsets.all(0.0),
                      );
                    }
                  },
                ),
              // ),
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          // child: Icon(Icons.add),
          children: [
            SpeedDialChild(
                child: Icon(Icons.fastfood),
                backgroundColor: Colors.blue,
                label: 'Food & Drink',
                onTap: () {
                  MealEntry newMeal = MealEntry.newEntry();
                  _diaryEntryBloc.addEntry(newMeal);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MealEntryPage(
                                entry: newMeal,
                                onUpdate: (_) =>
                                    _diaryEntryBloc.fetchAllDiaryEntries(),
                              ),),);
                },),
            SpeedDialChild(
              child: Icon(Icons.arrow_drop_up),
              backgroundColor: Colors.purple,
              label: 'Bowel Movement',
              onTap: () => print('SECOND CHILD'),
            ),
            SpeedDialChild(
              child: Icon(Icons.face),
              backgroundColor: Colors.red,
              label: 'Symptom',
              onTap: () => print('THIRD CHILD'),
            ),
            SpeedDialChild(
              child: Icon(Icons.pause_circle_outline),
              backgroundColor: Colors.orange,
              label: 'Medicine',
              onTap: () => print('THIRD CHILD'),
            ),
          ],
        ),);
  }
}

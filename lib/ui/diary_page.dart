import 'package:flutter/material.dart';
import 'diary_tiles.dart';
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
    _diaryEntryBloc.fetchAllDiaryEntries();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: _diaryEntryBloc.allFoods,
            builder: (context, AsyncSnapshot<List<DiaryEntry>> snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CircularProgressIndicator()),
                  ]
                );
              } else {
                List<DiaryEntry> entries = snapshot.data;
                return ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: entries.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(1.0),
                    child: buildEntryTile(entries[index]),
                  ),
                  padding: EdgeInsets.all(0.0),
                );
              }
            },
          )
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
              MealEntry newMeal = MealEntry();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MealEntryPage(
                  entry: newMeal,
                  onUpdate: (e) => _diaryEntryBloc.addEntry(e),
                )
              ));
            }
          ),
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
      )
    );
  }
}

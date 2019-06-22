import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gut_ai/blocs/diary_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/diary_tiles.dart';
import 'meal_entry_page.dart';
import '../models/diary_entry.dart';
import '../blocs/diary_entry_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../blocs/database_state.dart';
import '../blocs/database_event.dart';

class DiaryPage extends StatefulWidget {
  static String tag = 'diary-page';
  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {
  Widget buildEntryTile(DiaryEntry entry) {
    final diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    if (entry is MealEntry) {
      return MealEntryListTile(
        entry: entry,
        // onUpdate: (e) => setState(() => entry = e),
        // onUpdate: (e) => diaryEntryBloc.dispatch(Upsert(e)),
      );
    }
    if (entry is BowelMovementEntry) {
      return BowelMovementEntryListTile(entry);
    }
    if (entry is DosesEntry) {
      return DosesEntryListTile(
        entry: entry,
      );
    }
    if (entry is SymptomEntry) {
      return SymptomEntryListTile(
        entry: entry,
        onSaved: (e) => diaryEntryBloc.dispatch(Upsert(e)),
        // onSaved: (e) => setState(() => entry = e),
      );
    }
    return null;
  }

  List<Widget> entryToTiles(List<DiaryEntry> entry) {
    if (entry == []) {
      return [];
    }

    entry.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    var dateFormatter = DateFormat.yMd();

    List<Widget> tiles = [];
    for (var i = 0; i < entry.length; i++) {
      if (i == 0 ||
          dateFormatter.format(entry[i].dateTime) !=
              dateFormatter.format(entry[i - 1].dateTime)) {
        tiles.add(DateTile(dateTime: entry[i].dateTime));
      }
      tiles.add(buildEntryTile(entry[i]));
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    diaryEntryBloc.dispatch(FetchAll());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
      ),
      body: BlocBuilder(
        bloc: diaryEntryBloc,
        builder: (BuildContext context, DatabaseState state) {
          if (state is DatabaseLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
          if (state is DatabaseLoaded<DiaryEntry>) {
            List<Widget> tiles = entryToTiles(state.items.toList());
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
          if (state is DatabaseError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text('Error')),
              ],
            );
          }
        },
      ),
      floatingActionButton: DiaryFloatingActionButton(
        newMealTapped: () {
          MealEntry newMeal = MealEntry.newEntry();
          // diaryEntryBloc.insert(newMeal);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealEntryPage(
                    entry: newMeal,
                    // onUpdate: (_) => diaryEntryBloc.fetchAllDiaryEntry(),
                  ),
            ),
          );
        },
        newBowelMovementTapped: () => print('SECOND CHILD'),
        newMedicinesTapped: () => print('THIRD CHILD'),
        newSymptomTapped: () => print('FOURTH CHILD'),
      ),
    );
  }
}

typedef _Action = void Function();

class DiaryFloatingActionButton extends StatelessWidget {
  final _Action newMealTapped;
  final _Action newBowelMovementTapped;
  final _Action newMedicinesTapped;
  final _Action newSymptomTapped;

  DiaryFloatingActionButton({
    this.newMealTapped,
    this.newBowelMovementTapped,
    this.newMedicinesTapped,
    this.newSymptomTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      // child: Icon(Icons.add),
      children: [
        SpeedDialChild(
          child: Icon(Icons.fastfood),
          backgroundColor: Colors.blue,
          label: 'Food & Drink',
          onTap: newMealTapped,
        ),
        SpeedDialChild(
          child: Icon(Icons.arrow_drop_up),
          backgroundColor: Colors.purple,
          label: 'Bowel Movement',
          onTap: newBowelMovementTapped,
        ),
        SpeedDialChild(
          child: Icon(Icons.face),
          backgroundColor: Colors.red,
          label: 'Symptom',
          onTap: newMedicinesTapped,
        ),
        SpeedDialChild(
          child: Icon(Icons.pause_circle_outline),
          backgroundColor: Colors.orange,
          label: 'Medicine',
          onTap: newSymptomTapped,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gut_ai/resources/user_repository.dart';
import 'package:intl/intl.dart';
import 'meal_entry_page.dart';
import '../models/diary_entry.dart';
import '../blocs/diary_entry_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../blocs/database_state.dart';
import '../blocs/database_event.dart';
import '../resources/id_service.dart';

import '../pages/meal_entry_page.dart';
import '../pages/bm_entry_page.dart';
import '../pages/symptom_entry_page.dart';
import '../pages/doses_entry_page.dart';

class DiaryPage extends StatefulWidget {
  static String tag = 'diary-page';
  final UserRepository userRepository;

  DiaryPage({this.userRepository});

  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {
  Widget buildEntryTile(DiaryEntry entry) {
    final diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    if (entry is MealEntry) {
      return MealEntryListTile(
        entry: entry,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealEntryPage(
                      entry: entry,
                    ),
              ),
            ),
      );
    }
    if (entry is BowelMovementEntry) {
      return BowelMovementEntryListTile(
        entry: entry,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BMEntryPage(
                      entry: entry,
                    ),
              ),
            ),
      );
    }
    if (entry is DosesEntry) {
      return DosesEntryListTile(
        entry: entry,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DosesEntryPage(
                      entry: entry,
                    ),
              ),
            ),
      );
    }
    if (entry is SymptomEntry) {
      return SymptomEntryListTile(
        entry: entry,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SymptomEntryPage(entry: entry),
              ),
            ),
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
      floatingActionButton: DiaryFloatingActionButton(widget.userRepository),
    );
  }
}

class DiaryFloatingActionButton extends StatelessWidget {
  final UserRepository userRepository;

  DiaryFloatingActionButton(this.userRepository);

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
          onTap: () {
            IdService idService = IdService(userRepository);
            MealEntry newMeal =
                MealEntry.newEntry(idService.getId(), idService.getUserId());
            // diaryEntryBloc.insert(newMeal);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealEntryPage(
                      entry: newMeal,
                    ),
              ),
            );
          },
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
          onTap: () => print('FOURTH CHILD'),
        ),
      ],
    );
  }
}

class DiaryEntryListTile extends StatelessWidget {
  final String heading;
  final Iterable<String> subheadings;
  final DateTime datetime;
  final Color barColor;
  final Function onTap;

  DiaryEntryListTile(
      {this.heading,
      this.subheadings,
      this.datetime,
      this.barColor,
      this.onTap});

  Widget buildTime() {
    var dateFormatter = DateFormat.jm();
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 6, 5, 0),
          child: Text(
            dateFormatter.format(datetime),
            textAlign: TextAlign.right,
          ),
        ),
        width: 80,
      ),
    );
  }

  Widget buildHeading() {
    return Text(
      this.heading,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }

  Widget buildSubheading() {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subheadings
            .map((s) => Container(
                  padding: EdgeInsets.all(3.0),
                  child: Text(s),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCenter() {
    List<Widget> children;
    if (subheadings == null) {
      children = [
        buildHeading(),
      ];
    } else {
      children = [
        buildHeading(),
        buildSubheading(),
      ];
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 3.0, color: this.barColor),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              buildTime(),
              buildCenter(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class MealEntryListTile extends StatelessWidget {
  final MealEntry entry;
  final void Function() onTap;

  MealEntryListTile({this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Food & Drink',
      subheadings: entry.meal.ingredients.map((e) => e.food.name),
      datetime: entry.dateTime,
      barColor: Colors.blue,
      onTap: onTap,
    );
  }
}

class BowelMovementEntryListTile extends StatelessWidget {
  final BowelMovementEntry entry;
  final void Function() onTap;

  BowelMovementEntryListTile({this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    // final diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    return DiaryEntryListTile(
      heading: 'Bowel Movement',
      datetime: entry.dateTime,
      barColor: Colors.purple,
      onTap: onTap,
    );
  }
}

class DosesEntryListTile extends StatelessWidget {
  final DosesEntry entry;
  final void Function() onTap;

  DosesEntryListTile({this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: 'Medicine',
      subheadings: entry.doses.map((d) => d.medicine.name),
      datetime: entry.dateTime,
      barColor: Colors.orange,
      onTap: onTap,
    );
  }
}

class SymptomEntryListTile extends StatelessWidget {
  final SymptomEntry entry;
  final void Function() onTap;

  SymptomEntryListTile({this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DiaryEntryListTile(
      heading: entry.symptom.name(),
      // subheadings: ['Severity: ' + entry.symptom.severity.toString()],
      datetime: entry.dateTime,
      barColor: Colors.red,
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealEntryPage(entry: entry))),
      onTap: onTap,
    );
  }
}

class DateTile extends StatelessWidget {
  final DateTime dateTime;

  DateTile({this.dateTime});

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormat.MMMEd();

    return Container(
      padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
      color: Colors.grey,
      child: Text(
        dateFormatter.format(dateTime),
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
      ),
    );
  }
}

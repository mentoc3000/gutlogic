import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:built_collection/built_collection.dart';
import '../models/diary_entry.dart';
import '../models/dose.dart';
import '../widgets/datetime_view.dart';
import '../widgets/gutai_card.dart';
import '../widgets/item_tile.dart';
import 'dose_entry_page.dart';
import '../widgets/notes_tile.dart';
import '../blocs/diary_entry_bloc.dart';
import '../blocs/database_event.dart';

class DosesEntryPage extends StatefulWidget {
  static String tag = 'medicine-entry-page';

  final DosesEntry entry;

  DosesEntryPage({this.entry});

  @override
  DosesEntryPageState createState() => DosesEntryPageState();
}

class DosesEntryPageState extends State<DosesEntryPage> {
  DosesEntry _entry;


  void deleteDose(Dose dose) {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    setState(() {
      _entry = _entry.rebuild((b) => b.doses.remove(dose));
    });
    diaryEntryBloc.dispatch(Upsert(_entry));
  }

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> doseTiles = _entry.doses.map((i) {
      return Dismissible(
        key: ObjectKey(i),
        child: DoseTile(
          dose: i,
          dosesEntry: _entry,
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoseEntryPage(dose: i),
                ),
              ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            deleteDose(i);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text("${i.medicine.name} removed."),
              ),
            );
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      );
    }).toList();

    List<Widget> items = [
      DatetimeView(date: _entry.dateTime),
      GutAICard(
        child: Column(
          children: [
            HeaderListTile(
              heading: 'Doses',
            )
          ]..addAll(doseTiles),
        ),
      ),
      NotesTile(notes: _entry.notes),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Medicine'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) =>
            Padding(padding: EdgeInsets.all(1.0), child: items[index]),
        padding: EdgeInsets.all(0.0),
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: null),
    );
  }
}

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

class DosageEntryPage extends StatefulWidget {
  static String tag = 'medicine-entry-page';

  final DosageEntry entry;

  DosageEntryPage({this.entry});

  @override
  DosageEntryPageState createState() => DosageEntryPageState();
}

class DosageEntryPageState extends State<DosageEntryPage> {
  DosageEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  void _onSelectDose(Dose dose) {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoseEntryPage(
              dose: dose,
              onSave: (newDose) {
                //How to replace dose?
                // Replace old dose with new dose
                _entry = _entry.rebuild((b) => b
                  ..doses = BuiltList<Dose>(
                          _entry.doses.map((d) => dose == d ? newDose : d))
                      .toBuilder());
                diaryEntryBloc.dispatch(Update(_entry));
              },
            ),
      ),
    );
  }

  void _deleteDose(Dose dose) {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    setState(() {
      _entry = _entry.rebuild((b) => b.doses.remove(dose));
    });
    diaryEntryBloc.dispatch(Update(_entry));
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("${dose.medicine.name} removed."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> doseTiles = _entry.doses.map((dose) {
      return Dismissible(
        key: ObjectKey(dose),
        child: DoseTile(
          dose: dose,
          dosageEntry: _entry,
          onTap: () => _onSelectDose(dose),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            _deleteDose(dose);
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

    List<Widget> tiles = [
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
        itemCount: tiles.length,
        itemBuilder: (context, index) =>
            Padding(padding: EdgeInsets.all(1.0), child: tiles[index]),
        padding: EdgeInsets.all(0.0),
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: null),
    );
  }
}

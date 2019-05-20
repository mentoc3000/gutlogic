import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../models/dose.dart';
import '../widgets/datetime_view.dart';
import '../widgets/gutai_card.dart';
import '../widgets/item_tile.dart';
import 'dose_entry_page.dart';

class DosesEntryPage extends StatefulWidget {
  static String tag = 'medicine-entry-page';

  final DosesEntry entry;

  DosesEntryPage({this.entry});

  @override
  DosesEntryPageState createState() => DosesEntryPageState();
}

class DosesEntryPageState extends State<DosesEntryPage> {
  DosesEntry _entry;

  void deleteDose(Dose ingredient) {
    setState(() {
      _entry.doses.remove(ingredient);
    });
  }

  void newDose() {
    Dose newDose = Dose();
    setState(() {
      _entry.doses.add(newDose);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoseEntryPage(dose: newDose),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      DatetimeView(date: _entry.dateTime),
      GutAICard(
        child: Column(
          children: [
            HeaderListTile(
              heading: 'Doses',
            )
          ]..addAll(
              _entry.doses.map(
                (i) => Dismissible(
                      key: ObjectKey(i),
                      child: DoseTile(
                        dose: i,
                        dosesEntry: _entry,
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoseEntryPage(dose: i),
                              ),
                            ).then((_) => setState(() => _entry = _entry)),
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
                    ),
              ),
            ),
        ),
      )
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
          FloatingActionButton(child: Icon(Icons.add), onPressed: newDose),
    );
  }
}

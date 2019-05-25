import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/datetime_view.dart';
import '../widgets/gutai_card.dart';
import '../widgets/notes_tile.dart';

class BMEntryPage extends StatefulWidget {
  static String tag = 'bm-entry-page';

  final BowelMovementEntry entry;

  BMEntryPage({this.entry});

  @override
  BMEntryPageState createState() => BMEntryPageState();
}

class BMEntryPageState extends State<BMEntryPage> {
  List<Widget> items;

  @override
  void initState() {
    super.initState();

    this.items = <List<Widget>>[
      [
        DatetimeView(date: widget.entry.dateTime),
        BMTypeSliderTile(type: widget.entry.bowelMovement.type),
        BMVolumeSliderTile(volume: widget.entry.bowelMovement.volume),
        NotesTile(notes: widget.entry.notes),
      ],
    ].expand((x) => x).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.purple),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Bowel Movement'),
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) =>
              Padding(padding: EdgeInsets.all(1.0), child: items[index]),
          padding: EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}

class BMTypeSliderTile extends StatefulWidget {
  final int minimum = 1;
  final int maximum = 8;
  final int type;
  final List<String> descriptions = [
    'Type 1',
    'Type 2',
    'Type 3',
    'Type 4',
    'Type 5',
    'Type 6',
    'Type 7',
    'Type 8',
  ];

  BMTypeSliderTile({this.type: 5});

  @override
  _BMTypeSliderTileState createState() => _BMTypeSliderTileState();
}

class _BMTypeSliderTileState extends State<BMTypeSliderTile> {
  int value;
  String description;

  @override
  void initState() {
    super.initState();
    this.value = widget.type;
    this.description = widget.descriptions[widget.type - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GutAICard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Slider(
            min: widget.minimum.toDouble(),
            max: widget.maximum.toDouble(),
            value: value.toDouble(),
            divisions: widget.maximum - widget.minimum,
            onChanged: (newValue) => setState(() {
                  value = newValue.toInt();
                  description = widget.descriptions[value - 1];
                }),
          ),
          Text(description)
        ],
      ),
    );
  }
}

class BMVolumeSliderTile extends StatefulWidget {
  final int minimum = 1;
  final int maximum = 5;
  final int volume;
  final List<String> descriptions = [
    'Low Volume',
    'Moderately Low Volume',
    'Moderate Volume',
    'Moderately High Volume',
    'High Volume',
  ];

  BMVolumeSliderTile({this.volume: 3});

  @override
  _BMVolumeSliderTileState createState() => _BMVolumeSliderTileState();
}

class _BMVolumeSliderTileState extends State<BMVolumeSliderTile> {
  int value;
  String description;

  @override
  void initState() {
    super.initState();
    this.value = widget.volume;
    this.description = widget.descriptions[widget.volume - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GutAICard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Slider(
            min: widget.minimum.toDouble(),
            max: widget.maximum.toDouble(),
            value: value.toDouble(),
            divisions: widget.maximum - widget.minimum,
            onChanged: (newValue) => setState(() {
                  value = newValue.toInt();
                  description = widget.descriptions[value - 1];
                }),
          ),
          Text(description)
        ],
      ),
    );
  }
}

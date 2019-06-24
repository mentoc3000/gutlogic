import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/diary_entry.dart';
import '../widgets/datetime_view.dart';
import '../widgets/gutai_card.dart';
import '../widgets/notes_tile.dart';
import '../blocs/diary_entry_bloc.dart';
import '../blocs/database_event.dart';

class BMEntryPage extends StatelessWidget {
  static String tag = 'bm-entry-page';

  final BowelMovementEntry entry;

  BMEntryPage({this.entry});

  @override
  Widget build(BuildContext context) {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    List<Widget> tiles = <List<Widget>>[
      [
        DatetimeView(
          date: entry.dateTime,
          onChanged: (newValue) {
            final updatedEntry =
                entry.rebuild((b) => b..dateTime = newValue);
            diaryEntryBloc.dispatch(Upsert(updatedEntry));
          },
        ),
        BMTypeSliderTile(
          type: entry.bowelMovement.type,
          onChanged: (newValue) {
            final updatedEntry =
                entry.rebuild((b) => b..bowelMovement.type = newValue);
            diaryEntryBloc.dispatch(Upsert(updatedEntry));
          },
        ),
        BMVolumeSliderTile(
          volume: entry.bowelMovement.volume,
          onChanged: (newValue) {
            final updatedEntry =
                entry.rebuild((b) => b..bowelMovement.volume = newValue);
            diaryEntryBloc.dispatch(Upsert(updatedEntry));
          },
        ),
        NotesTile(
          notes: entry.notes,
          onChanged: (newValue) {
            final updatedEntry =
                entry.rebuild((b) => b..notes = newValue);
            diaryEntryBloc.dispatch(Upsert(updatedEntry));
          },
        ),
      ],
    ].expand((x) => x).toList();
    return Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.purple),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Bowel Movement'),
        ),
        body: ListView.builder(
          itemCount: tiles.length,
          itemBuilder: (context, index) =>
              Padding(padding: EdgeInsets.all(1.0), child: tiles[index]),
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
  final void Function(int) onChanged;

  BMTypeSliderTile({this.type: 5, this.onChanged});

  @override
  _BMTypeSliderTileState createState() => _BMTypeSliderTileState();
}

class _BMTypeSliderTileState extends State<BMTypeSliderTile> {
  int value;
  String description;
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

  @override
  void initState() {
    super.initState();
    this.value = widget.type;
    this.description = descriptions[widget.type - 1];
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
                  description = descriptions[value - 1];
                  widget.onChanged(value);
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
  final void Function(int) onChanged;

  BMVolumeSliderTile({this.volume: 3, this.onChanged});

  @override
  _BMVolumeSliderTileState createState() => _BMVolumeSliderTileState();
}

class _BMVolumeSliderTileState extends State<BMVolumeSliderTile> {
  int value;
  String description;
  final List<String> descriptions = [
    'Low Volume',
    'Moderately Low Volume',
    'Moderate Volume',
    'Moderately High Volume',
    'High Volume',
  ];

  @override
  void initState() {
    super.initState();
    this.value = widget.volume;
    this.description = descriptions[widget.volume - 1];
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
                  description = descriptions[value - 1];
                  
                  widget.onChanged(value);
                }),
          ),
          Text(description)
        ],
      ),
    );
  }
}

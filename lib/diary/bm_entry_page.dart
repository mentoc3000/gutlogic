import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/helpers/placeholder_widget.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';
import 'datetime_view.dart';
import 'package:gut_ai/generic_widgets/slider_tile.dart';
import 'bm_type_slider.dart';
import 'bm_volume_slider.dart';

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
          GutAIListTile(heading: 'Ingredients', adder: true,),
          BMTypeSliderTile(type: widget.entry.bowelMovement.type),
          BMVolumeSliderTile(volume: widget.entry.bowelMovement.volume,)
        ],
      ].expand((x) => x).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Bowel Movement'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(1.0),
          child: items[index]
        ),
        padding: EdgeInsets.all(0.0),
      ),
    );
  }
}


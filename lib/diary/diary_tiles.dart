import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';
import 'package:intl/intl.dart';

class MealTileLarge extends StatelessWidget {
  final MealEntry entry;

  MealTileLarge({this.entry});
  
  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: entry.meal.name,
      subheading: entry.meal.ingredients.map((e) => e.food.name).join(', '),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.blue,),
    );
  }

}

class BowelMovementTile extends StatelessWidget {
  final BowelMovementEntry entry;

  BowelMovementTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: 'Type ' + entry.bowelMovement.type.toString(), 
      subheading: 'Volume: ' + entry.bowelMovement.volume.toString(),
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.purple,),
    );
  }

}

class MedicineTile extends StatelessWidget {
  final MedicineEntry entry;

  MedicineTile({this.entry});

  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: entry.medicine.name, 
      subheading: entry.dose,
      leading: TimeLeader(datetime: entry.dateTime, borderColor: Colors.orange,),
    );
  }

}

class TimeLeader extends StatelessWidget {
  final DateTime datetime;
  final Color borderColor;

  TimeLeader({this.datetime, this.borderColor});

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat.jm();
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 5, 20),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 3.0, color: this.borderColor)
        )
      ),
      child: SizedBox(
        width: 70.0,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 3, 0),
              child: Text(formatter.format(datetime))
            )
          ],
        )
      )
    );
  }
}
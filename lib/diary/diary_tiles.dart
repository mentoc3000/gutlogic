import 'package:flutter/material.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/generic_widgets/item_tile.dart';
import 'package:intl/intl.dart';

class FoodAndDrinkTileLarge extends StatelessWidget {
  final MealEntry entry;

  FoodAndDrinkTileLarge({this.entry});
  
  @override
  Widget build(BuildContext context) {
    return ItemTileLarge (
      heading: entry.meal.name,
      subheading: entry.meal.ingredients.fold('', (value, element) => value + ', ' + element.food.name),
      leading: TimeLeader(datetime: entry.dateTime,),
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
      leading: TimeLeader(datetime: entry.dateTime,),
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
      leading: TimeLeader(datetime: entry.dateTime,),
    );
  }

}

class TimeLeader extends StatelessWidget {
  final DateTime datetime;

  TimeLeader({this.datetime});

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat.jm();
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(formatter.format(datetime))
        ],
      )
    );
  }
}
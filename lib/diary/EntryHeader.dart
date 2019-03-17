import 'package:flutter/material.dart';

class EntryHeader extends StatelessWidget {
  final Color color;
  final String title;

  EntryHeader({this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            width: 80.0,
            margin: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.black)
            ),
            child: new Text("9:35 am"),
          ),
          Expanded(child: Container(
            margin: const EdgeInsets.fromLTRB(0.0, 15.0, 15.0, 15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.black),
              color: color
            ),
            child: new Text(title),
          )),
        ],
      ),
    );
  }
}

class FoodEntryHeader extends StatelessWidget {
  final String title = "Food & Drink";
  final Color backgroundColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return EntryHeader(title: title, color: backgroundColor);
  }
}

class BMEntryHeader extends StatelessWidget {
  final String title = "Bowel Movement";
  final Color backgroundColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return EntryHeader(title: title, color: backgroundColor);
  }
}

class MedicineEntryHeader extends StatelessWidget {
  final String title = "Medicine";
  final Color backgroundColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return EntryHeader(title: title, color: backgroundColor);
  }
}
import 'package:flutter/material.dart';
import 'package:gi_bliss/genericViews/itemTileLarge.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:gi_bliss/model/DiaryEntry.dart';
import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/helpers/Dummy.dart';

class Diary extends StatefulWidget {
  @override
  DiaryState createState() => DiaryState();
}

class DiaryState extends State<Diary> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Diary"),
      ),
      body: ListView(
        children: <Widget>[
          EntryHeader(title: "Breakfast", color: Colors.blue),
          ItemTileLarge("Banana", "1 each"),
          ItemTileLarge("Egg", "2 each"),
          EntryHeader(title: "Bowel Movement", color: Colors.red),
          ItemTileLarge("Moderate Consistency", "Moderate Volume"),
          EntryHeader(title: "Medicine", color: Colors.green),
          ItemTileLarge("Fiber", "2 Tbsp"),
          ItemTileLarge("Pro-8", "1 each"),
        ],
      ),
    );
  }
}

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


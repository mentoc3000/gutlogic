import 'package:flutter/material.dart';
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
          ListTile(
            title: Text("Banana"),
            subtitle: Text("1 each"),
            trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
          ),
          ListTile(
            title: Text("Egg"),
            subtitle: Text("2 each"),
            trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
          ),
          EntryHeader(title: "Bowel Movement", color: Colors.red),
          ListTile(
            title: Text("Moderate Consistency"),
            subtitle: Text("Moderate Volume"),
            trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
          ),
          EntryHeader(title: "Medicine", color: Colors.green),
          ListTile(
            title: Text("Fiber"),
            subtitle: Text("2 Tbsp"),
            trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
          ),
          ListTile(
            title: Text("Pro-8"),
            subtitle: Text("1 each"),
            trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
          ),
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


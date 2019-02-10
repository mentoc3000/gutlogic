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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: Calendar(isExpandable: false,)
        ),
      ),
      body: ListView(
        children: <Widget>[
          EntryHeader(title: "Breakfast", color: Colors.green,)
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
            width: 100.0,
            // margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.black)
            ),
            child: new Text("9:35 am"),
          ),
          Container(
            // margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.black),
              color: color
            ),
            child: new Text(title),
          ),
        ],
      ),
    );
  }
}
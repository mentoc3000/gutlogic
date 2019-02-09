import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

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
          child: Calendar()
        ),
      ),
      body: ListView(
        children: <Widget>[],
      ),
    );
  }
}

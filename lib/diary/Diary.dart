import 'package:flutter/material.dart';

class Diary extends StatefulWidget {
  @override
  DiaryState createState() => new DiaryState();
}

class DiaryState extends State<Diary> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Diary"),
      ),
      body: new ListView(
        children: <Widget>[],
      ),
    );
  }
}
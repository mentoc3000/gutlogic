import 'package:flutter/material.dart';

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
        title: Text("Thur., Feb. 7, 2019"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(

          ),
        ),
      ),
      body: ListView(
        children: <Widget>[],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:gi_bliss/model/Food.dart';

class FoodSheet extends StatelessWidget {
  final Food food;

  FoodSheet({this.food});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(food.name)
      ),
      body: new ListView(
        children: <Widget>[
          _OverallAssessmentCard(irritants: food.irritants)
        ],
      )
    );
  }
}

class _OverallAssessmentCard extends StatelessWidget {
  final int sensitivity;

  _OverallAssessmentCard({Map<String,int> irritants}) : 
    this.sensitivity = irritants.values.reduce(max);

  @override
  Widget build(BuildContext context) {
    return new Card(
      key: ValueKey("overall"),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            "Overall",
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)
          ),
          trailing: new Container(
            width: 30.0,
            height: 30.0,
            decoration: new BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle
            ),
          ),
        )
      )
    );
  }
  
}
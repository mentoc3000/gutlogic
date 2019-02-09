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
          _OverallAssessmentCard(irritants: food.irritants),
          _IrritantsAssessmentCard(irritants: food.irritants)
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
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            "Overall",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
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

class _IrritantsAssessmentCard extends StatelessWidget {
  final Map<String, int> irritants;

  _IrritantsAssessmentCard({this.irritants});

  @override
  Widget build(BuildContext context) {
    return new Card(
      key: ValueKey("irritants"),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        child: new Column(
          children: <Widget>[
            new Text("Irritants"),
            new _IrritantAssessmentWidget(name: irritants.keys.elementAt(0), sensitivity: irritants.values.elementAt(0))
          ],
        ),
      ),

    );
  }
}

class _IrritantAssessmentWidget extends StatelessWidget {
  final String name;
  final int sensitivity;

  _IrritantAssessmentWidget({this.name, this.sensitivity});

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
      child: new Column(
        children: <Widget>[
          new Text(name),
          new Row(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: new BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle
                    ),
                  ),
                  new Text("1/4 Cup")
                ],
              ),
              new Column(
                children: <Widget>[
                  new Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: new BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle
                    ),
                  ),
                  new Text("1/2 Cup")
                ],
              ),
              new Column(
                children: <Widget>[
                  new Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle
                    ),
                  ),
                  new Text("1 Cup")
                ],
              )
            ],
          )
        ],
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:gi_bliss/model/Food.dart';

class FoodSheetPage extends StatelessWidget {
  final Food food;

  FoodSheetPage({this.food});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(food.name)
      ),
      body: new ListView(
        children: <Widget>[
          _OverallAssessmentCard(),
          _IrritantsAssessmentCard(irritants: food.irritants),
          _NutritionCard()
        ],
      )
    );
  }
}

class _OverallAssessmentCard extends StatelessWidget {

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
  final List<String> irritants;

  _IrritantsAssessmentCard({this.irritants});

  @override
  Widget build(BuildContext context) {
    return new Card(
      key: ValueKey("irritants"),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              "Irritants",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
            ),
            new Column(
              children: irritants.map((name) => new _IrritantAssessmentWidget(name: name, sensitivity: name.hashCode%2)).toList(),
            )
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
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(name, style: TextStyle(fontStyle: FontStyle.italic)),
          new Container( 
            // padding: const EdgeInsets.only(top: 10.0),
            child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
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
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
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
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
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
          ))
        ],
      )
    );
  }
}



class _NutritionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Card(
      key: ValueKey("irritants"),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              "Nutrition",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

    );
  }
}

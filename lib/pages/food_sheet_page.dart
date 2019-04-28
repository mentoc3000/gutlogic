import 'package:flutter/material.dart';
import '../models/food.dart';
import '../widgets/gutai_card.dart';

class FoodSheetPage extends StatelessWidget {
  final Food food;

  FoodSheetPage({this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.name)
      ),
      body: ListView(
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
    return GutAICard(
      key: ValueKey("overall"),
      child: Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            "Overall",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
          ),
          trailing: Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
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
    return GutAICard(
      key: ValueKey("irritants"),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Irritants",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
            ),
            Column(
              children: irritants.map((name) => _IrritantAssessmentWidget(name: name, sensitivity: name.hashCode%2)).toList(),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name, style: TextStyle(fontStyle: FontStyle.italic)),
          Container( 
            // padding: const EdgeInsets.only(top: 10.0),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle
                    ),
                  ),
                  Text("1/4 Cup")
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle
                    ),
                  ),
                  Text("1/2 Cup")
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle
                    ),
                  ),
                  Text("1 Cup")
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
    return GutAICard(
      key: ValueKey("irritants"),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Nutrition",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

    );
  }
}

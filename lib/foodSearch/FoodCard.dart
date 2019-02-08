import 'package:flutter/material.dart';
import 'FoodSheet.dart';
import 'package:gi_bliss/model/Food.dart';

class FoodCard extends StatelessWidget {
  final Food food;

  FoodCard(this.food);

  @override
  Widget build(BuildContext context) {
    return new Card(
      key: ValueKey(food.name),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            food.name,
            style: TextStyle(fontWeight: FontWeight.bold)
          ),
          subtitle: Row(
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: food.irritants.keys.join(', '),
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                      ),
                      maxLines: 3,
                      softWrap: true,
                    )
                  ]
                )
              )
            ]
          ),
          trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => new FoodSheet(food: food)));
          }
        )
      )
    );
  }

}
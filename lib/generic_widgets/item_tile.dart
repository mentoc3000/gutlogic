import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';
import 'package:gut_ai/model/food.dart';
import 'package:gut_ai/food_search/food_sheet_page.dart';

class GutAIListTile extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget leading;
  final Function onTap;
  final double size;
  final bool dense;
  final Widget trailing;

  GutAIListTile({
    this.heading, 
    this.subheading, 
    this.sensitivity, 
    this.leading, 
    this.trailing, 
    this.onTap, 
    this.size, 
    this.dense=false});

  @override
  Widget build(BuildContext context) {
    Widget subheadingWidget;
    if (this.subheading == null) {
      subheadingWidget = null;
    } else {
      subheadingWidget = Text(this.subheading);
    }
    return new ListTile(
      title: Text(this.heading),
      subtitle: subheadingWidget,
      leading: this.leading,
      trailing: this.trailing,
      onTap: this.onTap,
      dense: this.dense,
    );
  }

}

class FoodListTile extends StatelessWidget {

  final Food food;

  FoodListTile({this.food});

  @override
  Widget build(BuildContext context) {
    return GutAIListTile(
      heading: this.food.name,
      subheading: this.food.irritants.join(', '),
      trailing: Into(size: 30),
      size: 30, 
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FoodSheetPage(food: this.food)))
    );
  }
}


class Adder extends StatelessWidget {

  final double size;
  final Function onTap;

  Adder({this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(Icons.add, size: size),
      onTap: onTap,
    );
  }
}

class Into extends StatelessWidget {

  final double size;
  final Function onTap;

  Into({this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(Icons.keyboard_arrow_right, size: size),
      onTap: onTap,
    );
  }
}
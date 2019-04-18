import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';
import 'package:gut_ai/model/food.dart';
import 'package:gut_ai/model/bowel_movement.dart';
import 'package:gut_ai/model/ingredient.dart';
import 'package:gut_ai/model/medicine.dart';
import 'package:gut_ai/model/symptom.dart';
import 'package:gut_ai/food_search/food_sheet_page.dart';

class GutAIListTile extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget leading;
  final Function onTap;
  final double size;
  final bool dense;
  final bool adder;

  GutAIListTile({
    this.heading, 
    this.subheading, 
    this.sensitivity, 
    this.leading, 
    this.adder=false, 
    this.onTap, 
    this.size, 
    this.dense=false});

  static Widget _buildTrailing(bool adder, Sensitivity sensitivity, double size) {
    Widget trailingWidget;
    if (adder) {
      trailingWidget = Adder(size: size);
    } else if (sensitivity == null) {
      trailingWidget = Icon(Icons.keyboard_arrow_right, size: size);
    } else {
      // SizedBox is a workaround for an issue with unconstrained trailing widget size
      trailingWidget = SizedBox(
        width: 2 * size,
        child: Row(
          children: [
            SensitivityIndicator(sensitivity: sensitivity, size: size),
            Icon(Icons.keyboard_arrow_right, size: size),
          ]
        )
      );
    }
    return trailingWidget;
  }

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
      trailing: _buildTrailing(adder, sensitivity, size),
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
    return ListTile(
      title: Text(this.food.name),
      subtitle: Text(this.food.irritants.join(', ')),
      trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
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
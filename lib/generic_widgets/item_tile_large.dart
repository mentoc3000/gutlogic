import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';

class ItemTileLarge extends StatelessWidget {
  final String heading;
  final String subheading;

  ItemTileLarge({this.heading, this.subheading});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: Text(this.heading),
      subtitle: Text(this.subheading),
      // SizedBox is a workaround for an issue with unconstrained trailing widget size
      trailing: SizedBox(
        width: 60,
        child: Row(
          children: [
            SensitivityIndicatorLarge(sensitivity: Sensitivity.Major,),
            Icon(Icons.keyboard_arrow_right, size: 30.0),
          ]
        )
      )
    );
  }

}
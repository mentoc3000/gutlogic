import 'package:flutter/material.dart';
import '../../../style/gl_theme.dart';
import '../../../util/keys.dart';
import '../../../widgets/cards/gl_card.dart';

class OverallAssessmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLCard(
      key: Keys.overallFoodAssessment,
      child: Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: const Text('Overall', style: tileHeadingTheme),
          trailing: Container(
            width: 30.0,
            height: 30.0,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../style/gl_colors.dart';
import '../../../widgets/gl_icons.dart';

class FeatureList extends StatelessWidget {
  const FeatureList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          FeatureBox(text: 'Understand what triggers your symptoms'),
          FeatureBox(text: 'Find more foods to eat and to avoid'),
          FeatureBox(text: 'Watch your improvement over time'),
        ],
      ),
    );
  }
}

class FeatureBox extends StatelessWidget {
  final String text;

  const FeatureBox({required this.text});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16.0);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      // height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: GLColors.lightestGray,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(GLIcons.check, color: GLColors.green),
            ),
            Expanded(child: Text(text, style: style)),
          ],
        ),
      ),
    );
  }
}

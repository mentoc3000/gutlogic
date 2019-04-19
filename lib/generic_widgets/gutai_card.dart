import 'package:flutter/material.dart';

class GutAICard extends StatelessWidget {

  final Key key;
  final Widget child;

  GutAICard({this.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: child
    );
  }
}
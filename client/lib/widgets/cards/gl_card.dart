import 'package:flutter/material.dart';

class GLCard extends StatelessWidget {
  @override
  final Key key;
  final Widget child;

  GLCard({this.key, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GLCard extends StatelessWidget {
  final Widget child;

  const GLCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: child,
      ),
    );
  }
}

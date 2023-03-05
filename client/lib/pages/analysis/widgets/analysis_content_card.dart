import 'package:flutter/material.dart';

class AnalysisContentCard extends StatelessWidget {
  final Widget child;

  const AnalysisContentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(child: child),
    );
  }
}

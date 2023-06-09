import 'package:flutter/material.dart';

class GLLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Center(child: CircularProgressIndicator())],
    );
  }
}

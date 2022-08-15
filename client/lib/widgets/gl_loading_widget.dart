import 'package:flutter/material.dart';

class GLLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [Center(child: CircularProgressIndicator())],
    );
  }
}

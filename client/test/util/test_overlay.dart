import 'package:flutter/material.dart';

class TestOverlay extends StatelessWidget {
  final Widget child;
  const TestOverlay({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(600, 800), devicePixelRatio: 1.0),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Material(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

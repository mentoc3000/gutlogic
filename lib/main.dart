import 'package:flutter/material.dart';
import 'package:gi_bliss/mainTabs/MainTabs.dart';

void main() => runApp(GiBlissApp());

class GiBlissApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainTabs()
    );
  }
}

import 'package:flutter/material.dart';


class ItemTileLarge extends StatelessWidget {
  final String heading;
  final String subheading;

  ItemTileLarge(this.heading, this.subheading);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: Text(this.heading),
      subtitle: Text(this.subheading),
      trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
    );
  }

}
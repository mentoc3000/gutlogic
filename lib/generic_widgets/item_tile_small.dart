import 'package:flutter/material.dart';


class ItemTileSmall extends StatelessWidget {
  final String heading;
  final String subheading;

  ItemTileSmall({this.heading, this.subheading});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: new TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(text: this.heading, style: new TextStyle(fontWeight: FontWeight.bold)),
            new TextSpan(text: this.subheading, style: new TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
      trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
    );
  }

}
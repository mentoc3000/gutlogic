import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';

class ItemTileLarge extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget trailingWidget;
  final Widget leading;

  ItemTileLarge({this.heading, this.subheading, this.sensitivity, this.leading}) :
    this.trailingWidget = _buildTrailing(sensitivity);

  static Widget _buildTrailing(Sensitivity sensitivity) {
    Widget trailingWidget;
    if (sensitivity == null) {
      trailingWidget = Icon(Icons.keyboard_arrow_right, size: 30.0);
    } else {
      // SizedBox is a workaround for an issue with unconstrained trailing widget size
      trailingWidget = SizedBox(
        width: 60,
        child: Row(
          children: [
            SensitivityIndicatorLarge(sensitivity: sensitivity,),
            Icon(Icons.keyboard_arrow_right, size: 30.0),
          ]
        )
      );
    }
    return trailingWidget;
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: Text(this.heading),
      subtitle: Text(this.subheading),
      leading: this.leading,
      trailing: this.trailingWidget
    );
  }

}

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
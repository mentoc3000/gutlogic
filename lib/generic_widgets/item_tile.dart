import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';

class ItemTile extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget trailingWidget;
  final Widget leading;
  final Function onTap;
  final double size;

  ItemTile({this.heading, this.subheading, this.sensitivity, this.leading, this.onTap, this.size}) :
    this.trailingWidget = _buildTrailing(sensitivity, size);

  static Widget _buildTrailing(Sensitivity sensitivity, double size) {
    Widget trailingWidget;
    if (sensitivity == null) {
      trailingWidget = Icon(Icons.keyboard_arrow_right, size: size);
    } else {
      // SizedBox is a workaround for an issue with unconstrained trailing widget size
      trailingWidget = SizedBox(
        width: 2 * size,
        child: Row(
          children: [
            SensitivityIndicator(sensitivity: sensitivity, size: size),
            Icon(Icons.keyboard_arrow_right, size: size),
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
      trailing: this.trailingWidget,
      onTap: this.onTap
    );
  }

}

class ItemTileLarge extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget leading;
  final Function onTap;
  static double size = 30;

  ItemTileLarge({this.heading, this.subheading, this.sensitivity, this.leading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new ItemTile(
      heading: this.heading,
      subheading: this.subheading,
      leading: this.leading,
      sensitivity: this.sensitivity,
      onTap: this.onTap,
      size: ItemTileLarge.size
    );
  }

}

class ItemTileSmall extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget leading;
  final Function onTap;
  static double size = 15;

  ItemTileSmall({this.heading, this.subheading, this.sensitivity, this.leading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new ItemTile(
      heading: this.heading,
      subheading: this.subheading,
      leading: this.leading,
      sensitivity: this.sensitivity,
      onTap: this.onTap,
      size: ItemTileSmall.size
    );
  }
}

// class ItemTileSmall extends StatelessWidget {
//   final String heading;
//   final String subheading;

//   ItemTileSmall({this.heading, this.subheading});

//   @override
//   Widget build(BuildContext context) {
//     return new ListTile(
//       title: new RichText(
//         text: new TextSpan(
//           // Note: Styles for TextSpans must be explicitly defined.
//           // Child text spans will inherit styles from parent
//           style: new TextStyle(
//             fontSize: 14.0,
//             color: Colors.black,
//           ),
//           children: <TextSpan>[
//             new TextSpan(text: this.heading, style: new TextStyle(fontWeight: FontWeight.bold)),
//             new TextSpan(text: this.subheading, style: new TextStyle(fontStyle: FontStyle.italic)),
//           ],
//         ),
//       ),
//       trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
//     );
//   }

// }
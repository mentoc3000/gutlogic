import 'package:flutter/material.dart';
import 'sensitivity_indicator.dart';
import 'package:gut_ai/model/sensitivity.dart';

class GutAIListTile extends StatelessWidget {
  final String heading;
  final String subheading;
  final Sensitivity sensitivity;
  final Widget trailingWidget;
  final Widget leading;
  final Function onTap;
  final double size;
  final bool dense;
  final bool adder;

  GutAIListTile({
    this.heading, 
    this.subheading, 
    this.sensitivity, 
    this.leading, 
    this.adder=false, 
    this.onTap, 
    this.size, 
    this.dense=false
  }) :
    this.trailingWidget = _buildTrailing(adder, sensitivity, size);

  static Widget _buildTrailing(bool adder, Sensitivity sensitivity, double size) {
    Widget trailingWidget;
    if (adder) {
      trailingWidget = Icon(Icons.add, size: size);
    } else if (sensitivity == null) {
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
    Widget subheadingWidget;
    if (this.subheading == null) {
      subheadingWidget = null;
    } else {
      subheadingWidget = Text(this.subheading);
    }
    return new ListTile(
      title: Text(this.heading),
      subtitle: subheadingWidget,
      leading: this.leading,
      trailing: this.trailingWidget,
      onTap: this.onTap,
      dense: this.dense,
    );
  }

}


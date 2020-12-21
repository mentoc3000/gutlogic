import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The untitled back bar presents a back button without a page title.
class UntitledBackBar extends StatelessWidget {
  UntitledBackBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          child: const Icon(Icons.navigate_before),
          onTap: () => onBackButtonPressed(context),
        ),
      ],
    );
  }

  void onBackButtonPressed(BuildContext context) {
    Navigator.of(context).pop();
  }
}

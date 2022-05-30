import 'package:flutter/widgets.dart';

import 'button_helpers.dart';

class ShrinkWrappedButtonContent extends StatelessWidget {
  final String label;
  final Widget? leader;

  const ShrinkWrappedButtonContent({Key? key, required this.label, this.leader}) : super(key: key);

  factory ShrinkWrappedButtonContent.icon({Key? key, required String label, required IconData iconData}) {
    return ShrinkWrappedButtonContent(key: key, label: label, leader: Icon(iconData));
  }

  @override
  Widget build(BuildContext context) {
    final height = buttonHeight(context);
    final text = Text(label, textAlign: TextAlign.center);
    final showLeader = leader != null;

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLeader) leader!,
          if (showLeader) const SizedBox(width: 8),
          text,
        ],
      ),
    );
  }
}

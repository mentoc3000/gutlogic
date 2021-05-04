import 'package:flutter/widgets.dart';

import 'button_helpers.dart';

class StretchedButtonContent extends StatelessWidget {
  final String label;
  final Widget? leader;

  const StretchedButtonContent({Key? key, required this.label, this.leader}) : super(key: key);

  factory StretchedButtonContent.icon({Key? key, required String label, required IconData iconData}) =>
      StretchedButtonContent(key: key, label: label, leader: Icon(iconData));

  @override
  Widget build(BuildContext context) {
    final height = buttonHeight(context);
    final showLeader = leader != null;
    final text = Text(label, textAlign: TextAlign.center);

    return Container(
      height: height,
      child: Row(
        children: [
          if (showLeader) leader!,
          const Spacer(),
          text,
          const Spacer(),
          if (showLeader) // empty widget of size of leader
            Visibility(
              child: leader!,
              visible: false,
              maintainAnimation: true,
              maintainState: true,
              maintainSize: true,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

class StretchedButtonContent extends StatelessWidget {
  final String label;
  final Widget? leader;

  const StretchedButtonContent({Key? key, required this.label, this.leader}) : super(key: key);

  factory StretchedButtonContent.icon({Key? key, required String label, required IconData iconData}) =>
      StretchedButtonContent(key: key, label: label, leader: Icon(iconData));

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AspectRatio(aspectRatio: 1, child: leader ?? const SizedBox.shrink()),
      Expanded(
        child: Text(
          label,
          softWrap: false,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        ),
      ),
      const AspectRatio(aspectRatio: 1, child: SizedBox.shrink()),
    ]);
  }
}

import 'package:flutter/widgets.dart';

import '../gl_icons.dart';
import 'gl_card.dart';

class PushCard extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;

  const PushCard({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GLCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              child,
              const Icon(GLIcons.arrowRight),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../style/gl_colors.dart';
import 'gl_icons.dart';

class IrritantWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(GLIcons.irritantWarning, color: GLColors.gold);
  }
}

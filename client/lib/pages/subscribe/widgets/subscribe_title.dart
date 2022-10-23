import 'package:flutter/widgets.dart';

import '../../../style/gl_colors.dart';
import '../../../style/gl_text_style.dart';

class PremiumLogo extends StatelessWidget {
  const PremiumLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final whiteFont = logoFont.copyWith(color: GLColors.white);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('gut logic', style: whiteFont.copyWith(fontSize: 20)),
        Text('premium', style: whiteFont.copyWith(fontSize: 56)),
      ],
    );
  }
}

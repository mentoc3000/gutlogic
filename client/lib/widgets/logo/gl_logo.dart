import 'package:flutter/widgets.dart';

import '../../style/gl_text_style.dart';

class GLLogo extends StatelessWidget {
  final bool text;

  const GLLogo({this.text = false});

  @override
  Widget build(BuildContext context) {
    if (text) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/logo_trans.png', height: 200),
          Text('gut logic', style: logoFont.copyWith(fontSize: 48)),
        ],
      );
    } else {
      return Image.asset('assets/logo_trans.png', height: 200);
    }
  }
}

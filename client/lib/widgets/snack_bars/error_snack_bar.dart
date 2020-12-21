import 'package:flutter/widgets.dart';

import '../../style/gl_color_scheme.dart';
import 'gl_snack_bar.dart';

class ErrorSnackBar extends GLSnackBar {
  ErrorSnackBar({
    Key key,
    @required String text,
  }) : super(
          key: key,
          text: text,
          textColor: glColorScheme.onError,
          backgroundColor: glColorScheme.error,
        );
}

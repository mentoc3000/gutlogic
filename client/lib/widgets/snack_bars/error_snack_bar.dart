import 'package:flutter/material.dart';

import '../../blocs/bloc_helpers.dart';
import '../../style/gl_color_scheme.dart';
import 'gl_snack_bar.dart';

class ErrorSnackBar extends GLSnackBar {
  ErrorSnackBar({
    Key? key,
    required String text,
  }) : super(
          key: key,
          text: text,
          textColor: glColorScheme.onError,
          backgroundColor: glColorScheme.error,
        );

  /// When [state] is an instance of [ErrorState], this function shows the error message in an [ErrorSnackBar].
  ///
  /// Pair this with BlocListener to automatically show error messages.
  static void listen(BuildContext context, dynamic state) {
    if (state is ErrorState) {
      final widget = ErrorSnackBar(text: state.message ?? 'Uh oh, something went wrong.');
      ScaffoldMessenger.of(context).showSnackBar(widget);
    }
  }
}

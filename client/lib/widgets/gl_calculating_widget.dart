import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../style/gl_colors.dart';

class GLCalculatingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Center(child: _CalculatingIndicator())],
    );
  }
}

class _CalculatingIndicator extends StatelessWidget {
  const _CalculatingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SpinKitFadingFour(
      size: 50.0,
      color: GLColors.green,
    );
  }
}

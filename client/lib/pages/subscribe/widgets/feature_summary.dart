import 'package:flutter/widgets.dart';

import '../../../style/gl_colors.dart';

class FeatureSummary extends StatelessWidget {
  const FeatureSummary({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: GLColors.white,
      fontSize: 20.0,
      height: 1.4,
    );
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Text(
          'Make sense of your symptoms',
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

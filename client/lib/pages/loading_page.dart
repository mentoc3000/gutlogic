import 'package:flutter/widgets.dart';

import '../widgets/gl_circular_progress_indicator.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [Center(child: GLCircularProgressIndicator())],
    );
  }
}

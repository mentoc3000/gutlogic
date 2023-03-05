import 'package:flutter/widgets.dart';

import '../../../style/gl_text_style.dart';

class NoFoodsWithIrritant extends StatelessWidget {
  final String irritantName;

  const NoFoodsWithIrritant({super.key, required this.irritantName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No foods in the Pantry\nare known to contain $irritantName',
        textAlign: TextAlign.center,
        style: guideTextStyle.copyWith(height: 1.5),
      ),
    );
  }
}

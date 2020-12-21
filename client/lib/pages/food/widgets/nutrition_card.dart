import 'package:flutter/widgets.dart';
import '../../../style/gl_theme.dart';
import '../../../util/keys.dart';
import '../../../widgets/cards/gl_card.dart';

class NutritionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLCard(
      key: Keys.nutritionCard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition',
              style: tileHeadingTheme,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../../models/irritant.dart';
import '../../../style/gl_theme.dart';
import '../../../util/keys.dart';
import '../../../widgets/cards/gl_card.dart';
import 'irritant_assessment.dart';

class IrritantsAssessmentCard extends StatelessWidget {
  final Iterable<Irritant> irritants;

  const IrritantsAssessmentCard({required this.irritants});

  @override
  Widget build(BuildContext context) {
    return GLCard(
      key: Keys.irritantCard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Irritants', style: tileHeadingTheme),
            Column(
              children: irritants.map((i) => IrritantAssessment(name: i.name, sensitivity: i.hashCode % 2)).toList(),
            )
          ],
        ),
      ),
    );
  }
}

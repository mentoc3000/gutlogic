import 'package:flutter/widgets.dart';

import '../../routes/routes.dart';
import '../../style/gl_text_style.dart';
import '../gl_icons.dart';
import 'push_card.dart';

class PriorFoodsCard extends StatelessWidget {
  final DateTime dateTime;

  const PriorFoodsCard({Key? key, required this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PushCard(
      onTap: () => Navigator.of(context).push(Routes.of(context).createPriorFoodsPageRoute(dateTime: dateTime)),
      child: Row(
        children: const [
          Icon(GLIcons.priorFoods),
          SizedBox(width: 8),
          Text('Prior foods eaten', style: tileSubheadingStyle),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription.dart';
import '../../models/food_reference/food_reference.dart';
import '../../routes/routes.dart';
import '../../style/gl_color_scheme.dart';
import '../../style/gl_text_style.dart';
import 'push_card.dart';

class SimilarFoodsCard extends StatelessWidget {
  final FoodReference food;

  const SimilarFoodsCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      late final void Function()? onTap;
      final children = <Widget>[
        Row(
          children: const [
            Text('Foods with similar irritants', style: tileHeadingStyle),
          ],
        )
      ];

      if (state is Subscribed) {
        onTap = () => Navigator.push(context, Routes.of(context).createSimilarFoodsRoute(food: food));
      } else {
        onTap = () => Navigator.of(context).push(Routes.of(context).subscribe);
        children.addAll([
          const SizedBox(height: 4.0),
          Row(
            children: [
              const SizedBox(width: 32),
              Text(
                'Subscribe to unlock',
                style: TextStyle(color: glColorScheme.secondary),
              ),
            ],
          )
        ]);
      }

      // TODO: make style similar to prior foods card
      return PushCard(
        onTap: onTap,
        child: Column(children: children),
      );
    });
  }
}

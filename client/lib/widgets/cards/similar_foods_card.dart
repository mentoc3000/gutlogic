import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription.dart';
import '../../models/food_reference/food_reference.dart';
import '../../routes/routes.dart';
import '../gl_icons.dart';
import 'subscribe_to_unlock_push_card.dart';

class SimilarFoodsCard extends StatelessWidget {
  final FoodReference food;

  const SimilarFoodsCard({required this.food});

  @override
  Widget build(BuildContext context) {
    void onTapSubscribed() => Navigator.push(context, Routes.of(context).createSimilarFoodsRoute(food: food));
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      return SubscribeToUnlockPushCard(
        icon: GLIcons.similarFoods,
        text: 'Foods with similar irritants',
        onTapSubscribed: onTapSubscribed,
      );
    });
  }
}

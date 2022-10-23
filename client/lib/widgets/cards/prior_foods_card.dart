import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription.dart';
import '../../routes/routes.dart';
import '../gl_icons.dart';
import 'subscribe_to_unlock_push_card.dart';

class PriorFoodsCard extends StatelessWidget {
  final DateTime priorTo;

  const PriorFoodsCard({Key? key, required this.priorTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onTapSubscribed() =>
        Navigator.of(context).push(Routes.of(context).createPriorFoodsPageRoute(priorTo: priorTo));
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      return SubscribeToUnlockPushCard(
        icon: GLIcons.priorFoods,
        text: 'Prior foods eaten',
        onTapSubscribed: onTapSubscribed,
      );
    });
  }
}

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription.dart';
import '../../models/food/ingredient.dart';
import '../../models/irritant/intensity.dart';
import '../../resources/irritant_service.dart';
import '../../routes/routes.dart';
import '../gl_icons.dart';
import '../irritant_warning.dart';
import 'subscribe_to_unlock_push_card.dart';

class IngredientsCard extends StatelessWidget {
  final BuiltList<Ingredient> ingredients;

  const IngredientsCard({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final maxIntensity = context.select((IrritantService irritantService) {
      return irritantService.ofIngredients(ingredients, usePreferences: true).then((value) => value != null
          ? irritantService.maxIntensity(IrritantService.doseMap(value), usePreferences: true)
          : Future.value(Intensity.unknown));
    });

    void onTapSubscribed() =>
        Navigator.push(context, Routes.of(context).createIngredientsPageRoute(ingredients: ingredients));

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      return SubscribeToUnlockPushCard(
        icon: GLIcons.ingredients,
        text: 'Ingredients',
        onTapSubscribed: onTapSubscribed,
        trailing: FutureBuilder<Intensity>(
          future: maxIntensity,
          builder: (context, snapshot) {
            final showWarning = snapshot.hasData && snapshot.data != null && snapshot.data! > Intensity.none;
            return showWarning ? IrritantWarning() : Container();
          },
        ),
      );
    });
  }
}

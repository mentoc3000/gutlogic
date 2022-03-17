import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food/food.dart';
import '../../models/irritant/irritant.dart';
import '../../resources/irritant_repository.dart';
import 'expansion_card.dart';

class FoodDetailsCard extends StatelessWidget {
  final Food food;

  const FoodDetailsCard({required this.food});

  @override
  Widget build(BuildContext context) {
    final irritants = context.select((IrritantRepository irritantRepo) {
      return irritantRepo.ofRef(food.toFoodReference());
    });

    return FutureBuilder<BuiltList<Irritant>?>(
      future: irritants,
      builder: (context, snapshot) {
        final irritants = snapshot.data;
        final irritantNames = (irritants?.isEmpty ?? true)
            ? 'None'
            : (irritants!.where((i) => i.concentration > 0).map((i) => i.name).toList()..sort()).join('\n');
        return ExpansionCard(
          heading: 'Details',
          items: [
            if (food.brand != null) _TwoColumnListTile(label: 'Brand', value: food.brand!),
            if (irritants != null) _TwoColumnListTile(label: 'Irritants', value: irritantNames),
          ],
        );
      },
    );
  }
}

class _TwoColumnListTile extends StatelessWidget {
  final String label;
  final String value;

  const _TwoColumnListTile({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leftWidget = Text(label, style: const TextStyle(fontWeight: FontWeight.bold));
    final dots = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Image.asset('assets/dot.png', height: 16, repeat: ImageRepeat.repeatX),
    );
    final valueWidget = Text(value);

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [leftWidget, Expanded(child: dots), valueWidget],
      ),
      dense: true,
    );
  }
}

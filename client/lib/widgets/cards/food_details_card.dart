import 'package:flutter/material.dart';

import '../../models/food/food.dart';
import 'expansion_card.dart';

class FoodDetailsCard extends StatelessWidget {
  final Food food;

  const FoodDetailsCard({required this.food});

  @override
  Widget build(BuildContext context) {
    final foods = food.irritants!.isEmpty ? 'None' : (food.irritants!.map((i) => i.name).toList()..sort()).join(', ');
    return ExpansionCard(
      heading: 'Details',
      items: [
        if (food.brand != null) _TwoColumnListTile(left: 'Brand', right: food.brand!),
        if (food.irritants != null) _TwoColumnListTile(left: 'Irritants', right: foods),
      ],
    );
  }
}

class _TwoColumnListTile extends StatelessWidget {
  final String left;
  final String right;

  const _TwoColumnListTile({Key? key, required this.left, required this.right}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(left, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Image.asset('assets/dot.png', height: 16, repeat: ImageRepeat.repeatX),
            ),
          ),
          Flexible(child: Text(right), flex: 3),
        ],
      ),
      dense: true,
    );
  }
}

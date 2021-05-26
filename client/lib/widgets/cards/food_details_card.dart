import 'package:flutter/material.dart';

import '../../models/food/food.dart';
import 'expansion_card.dart';

class FoodDetailsCard extends StatelessWidget {
  final Food food;

  const FoodDetailsCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      heading: 'Details',
      items: [
        if (food.brand != null) _TwoColumnListTile(left: 'Brand', right: food.brand!, dense: true),
      ],
    );
  }
}

class _TwoColumnListTile extends StatelessWidget {
  final bool dense;
  final String left;
  final String right;

  const _TwoColumnListTile({Key? key, required this.left, required this.right, this.dense = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/dot.png', height: 16, repeat: ImageRepeat.repeatX),
            ),
          ),
          Text(right),
        ],
      ),
      dense: dense,
    );
  }
}

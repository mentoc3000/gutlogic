import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/irritant/irritant.dart';
import '../../resources/irritant_repository.dart';
import '../../style/gl_colors.dart';
import 'headed_card.dart';

class IrritantsCard extends StatelessWidget {
  final FoodReference foodReference;

  const IrritantsCard({required this.foodReference});

  @override
  Widget build(BuildContext context) {
    final irritants = context.select((IrritantRepository irritantRepo) {
      return irritantRepo.ofRef(foodReference);
    });

    return FutureBuilder<BuiltList<Irritant>?>(
      future: irritants,
      builder: (context, snapshot) {
        final irritants = snapshot.data;
        if (irritants == null) return Container();

        late final Widget content;
        if (irritants.isEmpty) {
          content = const SizedBox(height: 40);
        } else {
          final irritantsSorted = irritants.where((i) => i.concentration > 0).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          final rows = irritantsSorted.map((i) => _IrritantRow(irritant: i)).toList();
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: rows),
          );
        }

        return HeadedCard(heading: 'Irritants', content: content);
      },
    );
  }
}

class _IrritantRow extends StatelessWidget {
  final Irritant irritant;

  const _IrritantRow({Key? key, required this.irritant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intensityThresholds = context.select((IrritantRepository irritantRepo) {
      return irritantRepo.intensityThresholds(irritant);
    });

    return FutureBuilder<BuiltList<double>?>(
        future: intensityThresholds,
        builder: (context, snapshot) {
          final thresholds = snapshot.data;
          if (thresholds == null) return Container();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(irritant.name),
                _IrritantIndicator(irritant: irritant, intensityThresholds: thresholds),
              ],
            ),
          );
        });
  }
}

class _IrritantIndicator extends StatelessWidget {
  final Irritant irritant;
  final BuiltList<double> intensityThresholds;
  static const compartmentCount = 3;
  static const height = 16.0;
  static const width = 100.0;
  static const radius = height / 2;

  const _IrritantIndicator({Key? key, required this.irritant, required this.intensityThresholds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filledBoxes = List.generate(compartmentCount, (i) {
      late final double boxWidth;
      switch (i) {
        case 0:
          boxWidth = width * (i + 1) / compartmentCount + 0.6 * radius; // the 0.6 just makes it look better ¯\_(ツ)_/¯
          break;
        case 1:
          boxWidth = width * (i + 1) / compartmentCount + 0.5 * radius;
          break;
        default:
          boxWidth = width;
      }

      late final Color? color;
      if (irritant.dosePerServing > intensityThresholds[i]) {
        switch (i) {
          case 0:
            color = GLColors.lightGold;
            break;
          case 1:
            color = GLColors.gold;
            break;
          default:
            color = GLColors.darkGold;
        }
      } else {
        color = null;
      }

      return roundedBox(width: boxWidth, showBorder: true, color: color);
    }).reversed.toList();

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        ...filledBoxes,
        roundedBox(width: width, showBorder: true),
      ],
    );
  }

  Widget roundedBox({
    required double width,
    required bool showBorder,
    Color? color,
  }) {
    final decoration = BoxDecoration(
      border: showBorder ? Border.all(width: 2.0, color: GLColors.darkGray) : null,
      borderRadius: const BorderRadius.all(Radius.circular(radius)),
      color: color,
    );

    return Container(
      decoration: decoration,
      width: width,
      height: height,
    );
  }
}

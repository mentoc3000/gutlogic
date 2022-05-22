import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/irritant/irritant.dart';
import '../../resources/irritant_service.dart';
import '../irritant_intensity/intensity_indicator.dart';

class IrritantRows extends StatelessWidget {
  final BuiltList<Irritant>? irritants;

  const IrritantRows({required this.irritants});

  @override
  Widget build(BuildContext context) {
    final irritantsPresent = irritants?.where((i) => i.concentration > 0).toList();
    late final Widget child;
    if (irritantsPresent == null || irritantsPresent.isEmpty) {
      child = const Text('no known irritants');
    } else {
      final irritantsSorted = irritantsPresent..sort((a, b) => a.name.compareTo(b.name));
      final rows = irritantsSorted.map((i) => _IrritantRow(irritant: i)).toList();
      child = Column(children: rows);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: child,
    );
  }
}

class _IrritantRow extends StatelessWidget {
  final Irritant irritant;

  const _IrritantRow({Key? key, required this.irritant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intensityThresholds = context.read<IrritantService>().intensityThresholds(irritant);

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
              IntensityIndicator.fromIrritant(irritant: irritant, intensityThresholds: thresholds),
            ],
          ),
        );
      },
    );
  }
}

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../models/irritant/irritant.dart';
import '../irritant_intensity/irritant_rows.dart';
import 'headed_card.dart';

class IrritantsCard extends StatelessWidget {
  final BuiltList<Irritant> irritants;

  const IrritantsCard({required this.irritants});

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Irritants',
      content: IrritantRows(irritants: irritants),
    );
  }
}

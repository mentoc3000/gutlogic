import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../models/irritant/irritant.dart';
import '../../routes/routes.dart';
import '../../style/gl_colors.dart';
import '../gl_icons.dart';
import '../irritant_intensity/irritant_rows.dart';
import 'headed_card.dart';

class IrritantsCard extends StatelessWidget {
  final BuiltList<Irritant> irritants;
  final BuiltSet<String> excludedIrritants;

  const IrritantsCard({required this.irritants, required this.excludedIrritants});

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Irritants',
      trailing: IconButton(
        icon: Icon(GLIcons.filter, color: GLColors.darkGray),
        onPressed: () => Navigator.of(context).push(Routes.of(context).preferences),
      ),
      content: IrritantRows(irritants: irritants, excludedIrritants: excludedIrritants),
    );
  }
}

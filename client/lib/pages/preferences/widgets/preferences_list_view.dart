import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:gutlogic/models/preferences/preferences.dart';
import 'package:gutlogic/pages/preferences/widgets/irritant_toggle_tile.dart';
import 'package:gutlogic/pages/preferences/widgets/section_tile.dart';
import 'package:gutlogic/widgets/paywall.dart';

import '../../../style/gl_colors.dart';

class PreferencesListView extends StatelessWidget {
  final BuiltList<String> irritants;
  final Preferences preferences;
  final void Function(String, bool) onIrritantFilterChanged;

  const PreferencesListView({
    Key? key,
    required this.irritants,
    required this.preferences,
    required this.onIrritantFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const irritantFilterTitle = SectionTile(
      title: 'Irritant Visibility',
      subtitle: 'Show or hide irritants from foods\' FODMAP indicators. '
          'All irritants will still be visible on the food page.',
    );
    final irritantToggles = Paywall(
      color: GLColors.lightestGray,
      child: Column(
        children: irritants.sorted().map((i) {
          return IrritantToggleTile(
            irritant: i,
            include: !(preferences.irritantsExcluded?.contains(i) ?? false),
            onChanged: (value) => onIrritantFilterChanged(i, value),
          );
        }).toList(),
      ),
    );
    return ListView(children: [
      const Gap(8),
      irritantFilterTitle,
      irritantToggles,
      const Divider(color: Colors.grey),
    ]);
  }
}

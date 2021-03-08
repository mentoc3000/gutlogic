import 'package:flutter/widgets.dart';

import '../../../blocs/pantry_filter/pantry_filter.dart';
import '../../../models/pantry_filter.dart';
import '../../../models/sensitivity.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/gl_icons.dart';

class SensitivityFilter extends StatelessWidget {
  final PantryFilterCubit pantryFilterCubit;
  final PantryFilter filter;

  const SensitivityFilter({Key key, @required this.pantryFilterCubit, @required this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensitivities = [
      Sensitivity.unknown,
      Sensitivity.none,
      Sensitivity.mild,
      Sensitivity.moderate,
      Sensitivity.severe
    ];
    final sensitivityButtons = sensitivities
        .map((s) => _SensitivityFilterButton(
            color: GLColors.fromSensitivity(s),
            enabled: filter.isShown(s),
            onPressed: () => pantryFilterCubit.toggle(s)))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sensitivity'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: sensitivityButtons,
          )
        ],
      ),
    );
  }
}

class _SensitivityFilterButton extends StatelessWidget {
  final radius = 20.0;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _SensitivityFilterButton({Key key, @required this.color, @required this.enabled, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 2 * radius,
          width: 2 * radius,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: color,
          ),
          child: enabled ? const Icon(GLIcons.selected) : null,
        ),
      ),
    );
  }
}

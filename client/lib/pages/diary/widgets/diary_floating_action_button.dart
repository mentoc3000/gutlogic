import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../blocs/symptom_type/symptom_type.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_color_scheme.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/gl_icons.dart';
import '../../search_delegate/symptom_type_search_delegate.dart';

class DiaryFloatingActionButton extends StatelessWidget {
  const DiaryFloatingActionButton({Key? key}) : super(key: key);

  void showSymptomTypeSearch(BuildContext context) {
    final symptomTypeBloc = BlocProvider.of<SymptomTypeBloc>(context);

    showSearch(
      context: context,
      delegate: SymptomTypeSearchDelegate(
        symptomTypeBloc: symptomTypeBloc,
        onSelect: (symptomType) {
          Navigator.push(context, Routes.of(context).createSymptomEntryRouteFrom(symptomType: symptomType));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = SpeedDialChild(
      child: const Icon(GLIcons.meal),
      backgroundColor: GLColors.food,
      label: 'Food & Drink',
      onTap: () => Navigator.push(context, Routes.of(context).createMealEntryRoute()),
      foregroundColor: glColorScheme.onSecondary,
    );
    final bowelMovement = SpeedDialChild(
      child: const Icon(GLIcons.bowelMovement),
      backgroundColor: GLColors.bowelMovement,
      label: 'Bowel Movement',
      onTap: () => Navigator.push(context, Routes.of(context).createBowelMovementEntryRoute()),
      foregroundColor: glColorScheme.onSecondary,
    );
    final symptom = SpeedDialChild(
      child: const Icon(GLIcons.symptom),
      backgroundColor: GLColors.symptom,
      label: 'Symptom',
      onTap: () => showSymptomTypeSearch(context),
      foregroundColor: glColorScheme.onSecondary,
    );

    return SpeedDial(
      icon: GLIcons.add,
      activeIcon: GLIcons.clear,
      children: [food, symptom, bowelMovement],
      backgroundColor: glColorScheme.secondary,
      foregroundColor: glColorScheme.onSecondary,
    );
  }
}

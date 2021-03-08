import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/pantry_filter/pantry_filter.dart';
import '../../../models/pantry_filter.dart';
import '../../../style/gl_theme.dart';
import '../../../widgets/buttons/buttons.dart';
import 'sensitivity_filter.dart';

class PantryFilterWidget extends StatelessWidget {
  final PantryFilterCubit pantryFilterCubit;
  final void Function(BuildContext) onClose = Navigator.pop;

  PantryFilterWidget({Key key, @required this.pantryFilterCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryFilterCubit, PantryFilterState>(
      cubit: pantryFilterCubit,
      builder: (context, state) {
        final pantryFilter = state is Filter ? (state as Filter).filter : PantryFilter.all();
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            color: glTheme.scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter', style: tileHeadingTheme),
                    GLSecondaryButton(
                        onPressed: pantryFilterCubit.showAll, child: const ShrinkWrappedButtonContent(label: 'Clear')),
                  ],
                ),
                SensitivityFilter(pantryFilterCubit: pantryFilterCubit, filter: pantryFilter),
                GLPrimaryButton(onPressed: () => onClose(context), child: const StretchedButtonContent(label: 'Done')),
              ],
            ),
          ),
        );
      },
    );
  }
}

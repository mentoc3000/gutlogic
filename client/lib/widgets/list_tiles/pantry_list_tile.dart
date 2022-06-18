import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/pantry/pantry.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../routes/routes.dart';
import '../../widgets/alert_dialogs/confirm_delete_dialog.dart';
import '../../widgets/dismissible/delete_dismissible.dart';
import '../sensitivity_indicator.dart';
import 'push_list_tile.dart';

class PantryListTile extends StatelessWidget {
  final PantryEntry pantryEntry;
  final VoidCallback? onTap;

  const PantryListTile({Key? key, required this.pantryEntry, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap ??
        () => Navigator.push(context, Routes.of(context).createPantryEntryPageRoute(pantryEntry: pantryEntry));

    return DeleteDismissible(
      child: PushListTile(
        heading: pantryEntry.searchHeading(),
        leading: SensitivityIndicator(Future.value(pantryEntry.sensitivity)),
        onTap: onTap,
      ),
      onDelete: () => context.read<PantryBloc>().add(DeletePantryEntry(pantryEntry)),
      confirmDismiss: (_) => showDialog(
        context: context,
        builder: (_) => ConfirmDeleteDialog(itemName: pantryEntry.foodReference.name),
      ),
    );
  }
}

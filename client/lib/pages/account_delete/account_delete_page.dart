import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../blocs/account_delete/account_delete.dart';
import '../../blocs/reauthenticate/reauthenticate.dart';
import '../../routes/routes.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/buttons/gl_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/page_column.dart';

class AccountDeletePage extends StatelessWidget {
  static Widget provisioned() => AccountDeleteCubit.provider(child: AccountDeletePage());

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountDeleteCubit, AccountDeleteState>(
      listener: listener,
      child: GLScaffold(
        appBar: GLAppBar(title: 'Delete Account'),
        body: ConstrainedScrollView(builder: (context, constraints) => AccountDeletePageBody()),
      ),
    );
  }

  void listener(BuildContext context, AccountDeleteState state) async {
    if (state == const AccountDeleteFailure.reauthenticate()) {
      final result = await Navigator.of(context).push(Routes.of(context).reauthenticate);
      if (result is ReauthenticateSuccess) await context.read<AccountDeleteCubit>().delete();
    }
  }
}

class AccountDeletePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        AccountDeleteWarning(),
        const Gap(20),
        AccountDeleteButton(),
      ]),
    );
  }
}

class AccountDeleteWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
        'Are you sure you want to delete your account? Your user data will be permanently deleted and unrecoverable.');
  }
}

class AccountDeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final submittable = context.select((AccountDeleteCubit cubit) {
      return cubit.state != const AccountDeleteFailure.reauthenticate() &&
          cubit.state is! AccountDeleteLoading &&
          cubit.state is! AccountDeleteSuccess;
    });

    return GLButton(
      child: const StretchedButtonContent(label: 'Permanently Delete Account'),
      textColor: Colors.white,
      color: Colors.redAccent,
      onPressed: submittable ? () => context.read<AccountDeleteCubit>().delete() : null,
    );
  }
}

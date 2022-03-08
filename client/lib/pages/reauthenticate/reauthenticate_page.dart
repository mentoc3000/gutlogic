import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/widgets/auth_widgets.dart';
import '../../blocs/reauthenticate/reauthenticate.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';

class ReauthenticatePage extends StatelessWidget {
  static Widget provisioned() {
    return ReauthenticateCubit.provider(child: ReauthenticatePage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReauthenticateCubit, ReauthenticateState>(
      listener: listener,
      child: GLScaffold(
        appBar: GLAppBar(title: 'Reauthenticate'),
        body: SingleChildScrollView(child: ReauthenticatePageBody()),
      ),
    );
  }

  static void listener(BuildContext context, ReauthenticateState state) {
    if (state is ReauthenticateSuccess) Navigator.of(context).pop(state);
  }
}

class ReauthenticatePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AuthSection(onAuthentication: (auth) => context.read<ReauthenticateCubit>().reauthenticate(auth)),
        ],
      ),
    );
  }
}

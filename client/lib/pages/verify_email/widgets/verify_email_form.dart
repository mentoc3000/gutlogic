import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/verify_email/verify_email.dart';
import '../../../resources/user_repository.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../style/gl_theme.dart';
import '../../../widgets/buttons/buttons.dart';

class VerifyEmailForm extends StatelessWidget {
  final String email;
  final String message;

  VerifyEmailForm({@required this.message, @required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyEmailBloc, VerifyEmailState>(listener: listener, builder: builder);
  }

  Widget builder(BuildContext context, VerifyEmailState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, textAlign: TextAlign.center, style: tileSubheadingTheme),
        Text(email, textAlign: TextAlign.center, style: tileSubheadingTheme),
        GLTertiaryButton(
            child: const StretchedButtonContent(label: 'Resend'), onPressed: () => onResendPressed(context)),
        GLTertiaryButton(child: const StretchedButtonContent(label: 'OK'), onPressed: () => onRefreshPressed(context)),
        GLTertiaryButton(child: const StretchedButtonContent(label: 'Back'), onPressed: () => onBackPressed(context)),
      ],
    );
  }

  void onResendPressed(BuildContext context) {
    context.bloc<VerifyEmailBloc>().add(VerifyEmailResendRequested());
  }

  void onRefreshPressed(BuildContext context) {
    context.bloc<VerifyEmailBloc>().add(VerifyEmailUserRefreshed());
  }

  void onBackPressed(BuildContext context) {
    context.bloc<VerifyEmailBloc>().add(VerifyEmailExitRequested());
  }

  void listener(BuildContext context, VerifyEmailState state) {
    if (state is VerifyEmailError) {
      showErrorSnackBar(context, state.message);
    }

    if (state is VerifyEmailValue && state.verified) {
      if (context.repository<UserRepository>().user.consented) {
        Navigator.of(context).pushAndRemoveUntil(Routes.of(context).main, (_) => false);
      } else {
        Navigator.of(context).pushReplacement(Routes.of(context).consent);
      }
    }
  }

  void showErrorSnackBar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: GLColors.red, content: Text(message)));
  }
}

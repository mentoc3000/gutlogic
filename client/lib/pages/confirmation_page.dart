import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/login/login.dart';
import '../resources/user_repository.dart';
import '../widgets/buttons/gl_button.dart';
import '../widgets/form_fields/gl_text_form_field.dart';
import '../widgets/gl_app_bar.dart';
import '../widgets/gl_circular_progress_indicator.dart';
import '../widgets/gl_scaffold.dart';
import '../widgets/snack_bars/error_snack_bar.dart';

class ConfirmationPage extends StatelessWidget {
  final String username;
  final UserRepository userRepository;

  ConfirmationPage({
    Key key,
    @required this.username,
    @required this.userRepository,
  })  : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Confirm Account'),
      body: ConfirmationForm(username: username),
    );
  }
}

class ConfirmationForm extends StatelessWidget {
  final String username;

  ConfirmationForm({
    Key key,
    @required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confirmationCodeController = TextEditingController();
//    LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);

    void _onSignupButtonPressed() {
//      loginBloc.add(ConfirmButtonPressed(
//        username: username,
//        confirmationCode: confirmationCodeController.text,
//      ));
    }

    void _onCancelButtonPressed() {
//      loginBloc.add(CancelButtonPressed());
    }

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (
        BuildContext context,
        LoginState state,
      ) {
        if (state is LoginError) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              ErrorSnackBar(text: '${state.message}'),
            );
          });
        }

        return Form(
          child: Column(
            children: [
              GLTextFormField(
                labelText: 'confirmation code',
                controller: confirmationCodeController,
              ),
              GLPrimaryRaisedButton(
                onPressed: state is! LoginLoading ? _onSignupButtonPressed : null,
                label: 'Confirm',
              ),
              GLSecondaryFlatButton(
                onPressed: state is! LoginLoading ? _onCancelButtonPressed : null,
                label: 'Cancel',
              ),
              Container(
                child: state is LoginLoading ? const GLCircularProgressIndicator() : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

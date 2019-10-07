import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../resources/user_repository.dart';

import '../blocs/authentication_bloc.dart';
import '../blocs/login_bloc.dart';
import '../blocs/login_state.dart';
import '../blocs/login_event.dart';

class ConfirmationPage extends StatefulWidget {
  final String username;
  final UserRepository userRepository;

  ConfirmationPage({
    Key key,
    @required this.username,
    @required this.userRepository,
  })  : assert(userRepository != null),
        super(key: key);

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  String get _username => widget.username;
  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Account'),
      ),
      body: ConfirmationForm(
        username: _username,
        authenticationBloc: _authenticationBloc,
        loginBloc: _loginBloc,
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}

class ConfirmationForm extends StatefulWidget {
  final String username;
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  ConfirmationForm({
    Key key,
    @required this.username,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  State<ConfirmationForm> createState() => _ConfirmationFormState();
}

class _ConfirmationFormState extends State<ConfirmationForm> {
  final _confirmationCodeController = TextEditingController();

  String get _username => widget.username;
  LoginBloc get _loginBloc => widget.loginBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState state,
      ) {
        if (state is LoginFailure) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

        return Form(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'confirmation code'),
                controller: _confirmationCodeController,
              ),
              RaisedButton(
                onPressed:
                    state is! LoginLoading ? _onSignupButtonPressed : null,
                child: Text('Confirm'),
              ),
              RaisedButton(
                onPressed:
                    state is! LoginLoading ? _onCancelButtonPressed : null,
                child: Text('Cancel'),
              ),
              Container(
                child:
                    state is LoginLoading ? CircularProgressIndicator() : null,
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

  _onSignupButtonPressed() {
    _loginBloc.dispatch(ConfirmButtonPressed(
      username: _username,
      confirmationCode: _confirmationCodeController.text,
    ));
  }

  _onCancelButtonPressed() {
    _loginBloc.dispatch(CancelButtonPressed());
  }
}

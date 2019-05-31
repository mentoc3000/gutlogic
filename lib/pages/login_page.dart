// import 'package:flutter/material.dart';
// import 'main_tabs.dart';
// import '../widgets/login_text_form_field.dart';
// import '../widgets/login_button.dart';

// class LoginPage extends StatefulWidget {
//   static String tag = 'login-page';
//   @override
//   _LoginPageState createState() => new _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     final logo = Hero(
//       tag: 'hero',
//       child: CircleAvatar(
//         backgroundColor: Colors.transparent,
//         radius: 48.0,
//         // child: Image.asset('assets/logo.png'),
//       ),
//     );

//     final email = LoginTextFormField(
//       hintText: 'Email',
//       // validator: emailValidator,
//     );

//     final password = LoginTextFormField(
//       hintText: 'Password', 
//       obscureText: true,
//       // validator: passwordValidator,
//     );

//     final loginAction = () {
//       Navigator.of(context).pushNamed(Tabbed.tag);
//     };

//     final loginButton = LoginButton(
//       label: 'Log In',
//       primary: true,
//       onPressed: loginAction
//     );

//     final forgotAction = () {
//       final snackBar = SnackBar(
//         content: Text('Check your email to reset your password.'),
//         action: SnackBarAction(
//           label: 'Close',
//           onPressed: () => Scaffold.of(context).removeCurrentSnackBar()
//         ),
//       );
//       Scaffold.of(context).showSnackBar(snackBar);
//     };

//     final forgotLabel = Column(
//       children: [
//         Align(
//           alignment: Alignment.centerRight,
//           child: FlatButton(
//             child: Text(
//               'Forgot password?',
//               style: TextStyle(color: Colors.black54),
//             ),
//             onPressed: forgotAction
//           )
//         )
//       ]
//     );

//     final signupAction = () {};

//     final signupButton = LoginButton(
//       label: 'Create Account',
//       primary: false,
//       onPressed: signupAction,
//     );

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: ListView(
//           shrinkWrap: true,
//           padding: EdgeInsets.only(left: 24.0, right: 24.0),
//           children: <Widget>[
//             logo,
//             SizedBox(height: 48.0),
//             email,
//             SizedBox(height: 8.0),
//             password,
//             forgotLabel,
//             SizedBox(height: 12.0),
//             loginButton,
//             signupButton
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../resources/user_repository.dart';

import '../blocs/authentication_bloc.dart';
import '../blocs/login_bloc.dart';
import '../blocs/login_state.dart';
import '../blocs/login_event.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

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
        title: Text('Login'),
      ),
      body: LoginForm(
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

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
                decoration: InputDecoration(labelText: 'username'),
                controller: _usernameController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'password'),
                controller: _passwordController,
                obscureText: true,
              ),
              RaisedButton(
                onPressed:
                    state is! LoginLoading ? _onLoginButtonPressed : null,
                child: Text('Login'),
              ),
              RaisedButton(
                onPressed:
                    state is! LoginLoading ? _onSignupButtonPressed : null,
                child: Text('Signup'),
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

  _onLoginButtonPressed() {
    _loginBloc.dispatch(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }

  _onSignupButtonPressed() {
    _loginBloc.dispatch(SignupPageButtonPressed());
  }
}

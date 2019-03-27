import 'package:flutter/material.dart';
import 'package:gut_ai/main_tabs.dart';
import 'login_text_form_field.dart';
import 'login_button.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        // child: Image.asset('assets/logo.png'),
      ),
    );

    final email = LoginTextFormField(
      hintText: 'Email',
      // validator: emailValidator,
    );

    final password = LoginTextFormField(
      hintText: 'Password', 
      obscureText: true,
      // validator: passwordValidator,
    );

    final loginAction = () {
      Navigator.of(context).pushNamed(Tabbed.tag);
    };

    final loginButton = LoginButton(
      label: 'Log In',
      primary: true,
      onPressed: loginAction
    );

    final forgotAction = () {
      final snackBar = SnackBar(
        content: Text('Check your email to reset your password.'),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () => Scaffold.of(context).removeCurrentSnackBar()
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    };

    final forgotLabel = Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            child: Text(
              'Forgot password?',
              style: TextStyle(color: Colors.black54),
            ),
            onPressed: forgotAction
          )
        )
      ]
    );

    final signupAction = () {};

    final signupButton = LoginButton(
      label: 'Create Account',
      primary: false,
      onPressed: signupAction,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            forgotLabel,
            SizedBox(height: 12.0),
            loginButton,
            signupButton
          ],
        ),
      ),
    );
  }
}

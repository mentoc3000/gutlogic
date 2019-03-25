import 'package:flutter/material.dart';
import 'package:gut_ai/main_tabs.dart';
import 'login_text_form_field.dart';

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

    final email = LoginTextFormField(hintText: 'Email',);

    final password = LoginTextFormField(hintText: 'Password', obscureText: true,);

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(Tabbed.tag);
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            child: Text(
              'Forgot password?',
              style: TextStyle(color: Colors.black54),
            ),
            onPressed: () {
              final snackBar = SnackBar(
                content: Text('Check your email to reset your password.'),
                action: SnackBarAction(
                  label: 'Close',
                  onPressed: () => Scaffold.of(context).removeCurrentSnackBar()
                ),
              );
              Scaffold.of(context).showSnackBar(snackBar);
            }
          )
        )
      ]
    );



    final signupButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () { },
        padding: EdgeInsets.all(12),
        color: Colors.grey,
        child: Text('Sign Up', style: TextStyle(color: Colors.blue)),
      ),
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

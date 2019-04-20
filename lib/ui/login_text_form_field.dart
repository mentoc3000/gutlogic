import 'package:flutter/material.dart';

class LoginTextFormField extends StatelessWidget {

  final String initialValue;
  final String hintText;
  final bool obscureText;

  LoginTextFormField({
    this.initialValue='', 
    this.hintText='', 
    this.obscureText=false,
  }) ;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      initialValue: this.initialValue,
      obscureText: this.obscureText,
      decoration: InputDecoration(
        hintText: this.hintText,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      // validator: this.validator,
    );
  }
}

String emailValidator(String value) {
  if (value.isEmpty) {
    return 'Please enter your email address.';
  } else {
    return null;
  }
}


String passwordValidator(String value) {
  if (value.isEmpty) {
    return 'Please enter your password.';
  } else {
    return null;
  }
}
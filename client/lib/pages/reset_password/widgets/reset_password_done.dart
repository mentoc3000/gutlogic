import 'package:flutter/widgets.dart';

class ResetPasswordDone extends StatelessWidget {
  final String email;

  ResetPasswordDone({this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Okay, if you signed up with $email we've sent you a link to reset your password."),
      ],
    );
  }
}

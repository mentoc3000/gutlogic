import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {

  final bool primary;
  final String label;
  final Function onPressed;

  LoginButton({this.label, this.primary=true, this.onPressed});

  Color backgroundColor() {
    if (this.primary) {
      return Colors.blueAccent;
    } else {
      return Colors.grey;
    }
  }

  Color textColor() {
    if (this.primary) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: this.onPressed,
        padding: EdgeInsets.all(12),
        color: this.backgroundColor(),
        child: Text(this.label, style: TextStyle(color: this.textColor())),
      ),
    );
  }
}
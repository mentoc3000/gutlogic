import 'package:flutter/material.dart';

class ChangePasswordUpgradeWarning extends StatelessWidget {
  final String email;

  ChangePasswordUpgradeWarning({this.email});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          'Hey, looks like your account was made without a password. No problem. You can set a new password here and start logging in with $email.',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onError,
          ),
        ),
      ),
    );
  }
}

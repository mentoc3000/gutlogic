import 'package:flutter/material.dart';

class UnitTextField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  UnitTextField({Key? key, required this.controller, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(hintText: 'Units'),
      controller: controller,
      textAlign: TextAlign.center,
      onChanged: onChanged,
    );
  }
}

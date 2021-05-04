import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GLTextFormField extends StatelessWidget {
  final String? labelText;
  final InputDecoration? decoration;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final bool autocorrect;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;

  const GLTextFormField({
    Key? key,
    this.controller,
    this.labelText,
    this.decoration,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.autocorrect = true,
    this.autovalidateMode = AutovalidateMode.always,
    this.validator,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: decoration,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      enabled: enabled,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autovalidateMode: autovalidateMode,
      validator: validator,
    );
  }
}

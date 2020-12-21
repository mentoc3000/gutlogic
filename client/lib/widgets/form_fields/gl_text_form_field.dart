import 'package:flutter/material.dart';

class GLTextFormField extends StatelessWidget {
  final String labelText;
  final IconData decorationIcon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final bool enabled;
  final bool obscureText;
  final bool autovalidate;
  final bool autocorrect;
  final String Function(String) validator;

  const GLTextFormField({
    Key key,
    this.controller,
    this.labelText,
    this.decorationIcon,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.autovalidate = false,
    this.autocorrect = false,
    this.validator,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = decorationIcon == null ? null : Icon(decorationIcon);

    return TextFormField(
      decoration: InputDecoration(
        icon: icon,
        labelText: labelText,
        // border: const OutlineInputBorder(),
      ),
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      enabled: enabled,
      obscureText: obscureText,
      autovalidate: autovalidate,
      autocorrect: autocorrect,
      validator: validator,
    );
  }
}

import 'package:flutter/material.dart' hide FormFieldBuilder;

import '../../input/input.dart';
import '../gl_icons.dart';

class PasswordField extends StatefulWidget {
  final InputText input;
  final String label;
  final bool? enabled;

  const PasswordField({
    Key? key,
    this.enabled,
    this.label = 'Password',
    required this.input,
  }) : super(key: key);

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Focus(child: InputBuilder(input: widget.input, builder: builder));
  }

  Widget builder(BuildContext context, InputState<String> state) {
    // Only show an error on dirty focused inputs.
    final errorText = state.dirty && Focus.of(context).hasFocus == false ? state.error : null;

    return TextField(
      enabled: widget.enabled,
      controller: widget.input.controller,
      decoration: InputDecoration(
        icon: const Icon(GLIcons.password),
        labelText: widget.label,
        suffixIcon: GestureDetector(
          onTap: () => setState(() => isObscured = !isObscured),
          child: Icon(isObscured ? GLIcons.visibility : GLIcons.visibilityOff),
        ),
        errorText: errorText,
      ),
      obscureText: isObscured,
      autocorrect: false,
    );
  }
}

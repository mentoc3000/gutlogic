import 'package:flutter/material.dart' hide FormFieldBuilder;

import '../../input/input.dart';
import '../gl_icons.dart';

class UsernameField extends StatelessWidget {
  final InputText input;
  final bool? enabled;

  UsernameField({
    Key? key,
    this.enabled,
    required this.input,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(child: InputBuilder(input: input, builder: builder));
  }

  Widget builder(BuildContext context, InputState<String> state) {
    // Only show an error on dirty unfocused inputs.
    final errorText = state.dirty && Focus.of(context).hasFocus == false ? state.error : null;

    return TextField(
      enabled: enabled,
      controller: input.controller,
      decoration: InputDecoration(
        icon: const Icon(GLIcons.email),
        labelText: 'Email',
        errorText: errorText,
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
    );
  }
}

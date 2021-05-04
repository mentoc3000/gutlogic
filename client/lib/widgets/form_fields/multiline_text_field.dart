import 'package:flutter/material.dart';

class MultilineTextField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const MultilineTextField({Key? key, required this.controller, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

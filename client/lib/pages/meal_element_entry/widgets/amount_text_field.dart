import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTextField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(double) onChanged;
  static int precision = 2;

  const AmountTextField({Key key, @required this.controller, @required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
      decoration: const InputDecoration(hintText: 'Amount'),
      controller: controller,
      textAlign: TextAlign.center,
      onChanged: (amount) => onChanged(amount.isEmpty ? null : double.parse(amount)),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]*\.[0-9]*|[0-9]+')),
      ],
    );
  }
}

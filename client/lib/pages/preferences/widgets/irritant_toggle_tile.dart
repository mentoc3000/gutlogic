import 'package:flutter/material.dart';

class IrritantToggleTile extends StatelessWidget {
  final String irritant;
  final bool include;
  final void Function(bool) onChanged;

  const IrritantToggleTile({
    Key? key,
    required this.irritant,
    required this.include,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(irritant),
      value: include,
      onChanged: onChanged,
    );
  }
}

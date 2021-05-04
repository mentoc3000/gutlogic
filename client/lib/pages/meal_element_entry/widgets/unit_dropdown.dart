import 'package:flutter/material.dart';

import '../../../style/gl_color_scheme.dart';

class UnitDropdown extends StatefulWidget {
  final String initialUnit;
  final Iterable<String> unitOptions;
  final void Function(String)? onChanged;

  UnitDropdown({Key? key, required this.initialUnit, required this.unitOptions, this.onChanged}) : super(key: key);

  @override
  _UnitDropdownState createState() => _UnitDropdownState(unit: initialUnit);
}

class _UnitDropdownState extends State<UnitDropdown> {
  String unit;

  _UnitDropdownState({required this.unit});

  @override
  Widget build(BuildContext context) {
    final items = widget.unitOptions
        .map((value) => DropdownMenuItem(value: value, child: Text(value, textAlign: TextAlign.center)))
        .toList();

    return DropdownButtonFormField(
      dropdownColor: glColorScheme.onSecondary,
      isExpanded: true,
      items: items,
      value: unit,
      onChanged: (value) {
        if (value is! String) return;
        setState(() => unit = value);
        widget.onChanged?.call(value);
      },
      hint: const Text('Unit'),
    );
  }
}

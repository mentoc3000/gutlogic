import 'package:flutter/material.dart';

class UnitDropdown extends StatefulWidget {
  final String initialUnit;
  final void Function(String) onChanged;
  final Iterable<String> unitOptions;

  UnitDropdown({Key key, String initialUnit, @required this.unitOptions, @required this.onChanged})
      : initialUnit = initialUnit ?? unitOptions.first,
        super(key: key);

  @override
  _UnitDropdownState createState() => _UnitDropdownState();
}

class _UnitDropdownState extends State<UnitDropdown> {
  String _unit;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.unitOptions
        .map((value) => DropdownMenuItem(
              value: value,
              child: Text(value, textAlign: TextAlign.center),
            ))
        .toList();

    return DropdownButtonFormField(
      items: items,
      value: _unit,
      onChanged: (newValue) {
        setState(() => _unit = newValue);
        widget.onChanged(newValue);
      },
      hint: const Text('Unit'),
    );
  }
}

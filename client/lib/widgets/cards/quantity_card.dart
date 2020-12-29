import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/quantity.dart';
import 'gl_card.dart';

class QuantityCard extends StatefulWidget {
  final Quantity quantity;
  final void Function(Quantity) onChanged;

  const QuantityCard({this.quantity, this.onChanged});

  @override
  _QuantityCardState createState() => _QuantityCardState();
}

class _QuantityCardState extends State<QuantityCard> {
  TextEditingController _amountController;
  TextEditingController _unitController;
  Quantity _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity ?? Quantity();
    _amountController = TextEditingController(text: _quantity.amount.toString());
    _unitController = TextEditingController(text: _quantity.measure.unit);
  }

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                decoration: const InputDecoration(hintText: 'Amount'),
                controller: _amountController,
                textAlign: TextAlign.center,
                onChanged: (String amount) {
                  _quantity = _quantity.rebuild((b) => b..amount = double.parse(amount));
                  widget.onChanged(_quantity);
                },
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9]*\.[0-9]+|[0-9]+')),
                ],
              ),
            ),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(hintText: 'Units'),
                controller: _unitController,
                textAlign: TextAlign.center,
                onChanged: (String unit) {
                  _quantity = _quantity.rebuild((b) => b..measure.unit = unit);
                  widget.onChanged(_quantity);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

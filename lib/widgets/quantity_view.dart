import 'package:flutter/material.dart';
import '../models/quantity.dart';
import 'gutai_card.dart';

class QuantityView extends StatefulWidget {
  final Quantity quantity;
  final void Function(Quantity) onChanged;

  QuantityView({this.quantity, this.onChanged});

  @override
  _QuantityViewState createState() => _QuantityViewState();
}

class _QuantityViewState extends State<QuantityView> {
  TextEditingController _amountController;
  TextEditingController _unitController;
  Quantity _quantity;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.quantity.amount.toString());
    _unitController = TextEditingController(text: widget.quantity.unit);
    _quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return GutAICard(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(hintText: 'Amount'),
                controller: _amountController,
                textAlign: TextAlign.center,
                onChanged: (String amount) {
                  _quantity = _quantity.rebuild((b) => b..amount = double.parse(amount));
                  widget.onChanged(_quantity);
                },
              ),
            ),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(hintText: 'Units'),
                controller: _unitController,
                textAlign: TextAlign.center,
                onChanged: (String unit) {
                  _quantity = _quantity.rebuild((b) => b..unit = unit);
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

import 'package:flutter/material.dart';
import '../models/quantity.dart';
import 'gutai_card.dart';

class QuantityView extends StatefulWidget {
  final Quantity quantity;

  QuantityView({this.quantity});

  @override
  _QuantityViewState createState() => _QuantityViewState();
}

class _QuantityViewState extends State<QuantityView> {
  TextEditingController _amountController;
  TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.quantity.amount.toString());
    _unitController = TextEditingController(text: widget.quantity.unit);
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
                  widget.quantity.amount = double.parse(amount);
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
                  widget.quantity.unit = unit;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

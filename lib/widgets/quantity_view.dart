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
  @override
  Widget build(BuildContext context) {
    return GutAICard(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(
                  hintText: 'Amount',
                ),
                textAlign: TextAlign.center,
                initialValue: widget.quantity.amount.toString(),
                onSaved: (String amount) {
                  widget.quantity.amount = double.parse(amount);
                },
              ),
            ),
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(hintText: 'Units'),
                textAlign: TextAlign.center,
                initialValue: widget.quantity.unit.toString(),
                onSaved: (String unit) {
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

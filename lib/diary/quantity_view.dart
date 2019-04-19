import 'package:flutter/material.dart';
import 'package:gut_ai/model/quantity.dart';
import 'package:gut_ai/generic_widgets/gutai_card.dart';

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
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                decoration: InputDecoration(
                  hintText: 'Amount',
                ),
                textAlign: TextAlign.center,
                onSaved: (String amount) {
                  widget.quantity.amount = double.parse(amount);
                },
              ),
            ),
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                decoration: InputDecoration(
                  hintText: 'Units'
                ),
                textAlign: TextAlign.center,
                onSaved: (String unit) {
                  widget.quantity.unit = unit;
                },
              ),
            )
          ],
        )
      )
    );
  }
}

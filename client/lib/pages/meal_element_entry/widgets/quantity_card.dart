import 'dart:math';

import 'package:flutter/material.dart';
import '../../../models/measure.dart';
import '../../../models/quantity.dart';
import '../../../widgets/cards/gl_card.dart';
import 'amount_text_field.dart';
import 'unit_dropdown.dart';
import 'unit_text_field.dart';

final _defaultQuantity = Quantity();

class QuantityCard extends StatelessWidget {
  final Quantity quantity;
  final void Function(Quantity) onChanged;
  final Iterable<Measure> measureOptions;
  final TextEditingController unitController;
  final TextEditingController amountController;

  /// A card widget to display and update a quantity
  ///
  /// If no [quantity] is provided then [Quantity()] is used.
  ///
  /// If [measureOptions] are provided, then the unit selector is a dropdown, limited choices to that selection.
  /// If [measureOptions] is not provided, then the unit input is a [TextField].
  QuantityCard(
      {Quantity quantity,
      @required this.onChanged,
      @required this.unitController,
      @required this.amountController,
      this.measureOptions})
      : quantity = quantity ?? _defaultQuantity;

  Widget _buildAmountInput(BuildContext context) {
    return AmountTextField(
      controller: amountController,
      onChanged: (amount) {
        final newQuantity = quantity.rebuild((b) => b..amount = amount);
        onChanged(newQuantity);
      },
    );
  }

  Widget _buildUnitInput(BuildContext context) {
    final initialUnit = quantity.measure?.unit;

    if (measureOptions == null) {
      return UnitTextField(
        controller: unitController,
        onChanged: (String unit) => onChanged(quantity.rebuild((b) => b.measure = Measure(unit: unit).toBuilder())),
      );
    } else {
      return Center(
        child: UnitDropdown(
          initialUnit: initialUnit,
          unitOptions: measureOptions.map((e) => e.unit),
          onChanged: (String unit) {
            final measure = measureOptions.firstWhere((m) => m.unit == unit);
            final newQuantity = quantity.convertTo(measure);
            amountController.text = formatAmount(newQuantity.amount);
            onChanged(newQuantity);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Row(
          children: [
            Flexible(child: _buildAmountInput(context)),
            Flexible(child: _buildUnitInput(context)),
          ],
        ),
      ),
    );
  }

  static String formatAmount(double amount) {
    if (amount == null) return null;

    final transformer = pow(10, AmountTextField.precision);
    final rounded = (amount * transformer).round() / transformer;

    // If the amount is an integer, don't show the decimal
    if (rounded == rounded.floor()) {
      return rounded.floor().toString();
    } else {
      return rounded.toString();
    }
  }
}

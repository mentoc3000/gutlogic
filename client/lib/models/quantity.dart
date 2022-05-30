import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'measure.dart';

part 'quantity.g.dart';

abstract class Quantity implements Built<Quantity, QuantityBuilder> {
  static Serializer<Quantity> get serializer => _$quantitySerializer;

  double? get amount;
  Measure? get measure;

  Quantity._();

  factory Quantity({double? amount, Measure? measure}) = _$Quantity._;

  factory Quantity.fromBuilder([QuantityBuilder Function(QuantityBuilder) updates]) = _$Quantity;

  factory Quantity.unweighed({required double amount, required String unit}) {
    return Quantity(amount: amount, measure: Measure(unit: unit));
  }

  @override
  String toString() => '$amount ${measure?.unit}';

  /// Convert to quantity with a new Measure
  ///
  /// ```dart
  /// final cup = Quantity(amount: 1, measure: Measure(unit: 'Cup', weight: 240));
  /// final tbsp = cup.convertTo(Measure(unit: 'Tablespoon', weight: 15));
  /// tbsp == Quantity(amount: 16, measure: Measure(unit: 'Tablespoon', weight: 15));
  /// ```
  ///
  /// If either the weight of this measure or the new measure is null, the resulting [Quantity] will have the same
  /// amount as the input and a measure with a null weight.
  Quantity convertTo(Measure? measure) {
    if (this.measure == null || measure == null) {
      return Quantity(amount: this.amount, measure: measure);
    }
    if (this.measure!.weight == null || measure.weight == null) {
      return Quantity(amount: this.amount, measure: Measure(unit: measure.unit));
    }
    if (this.amount == null) {
      return Quantity(measure: measure);
    }
    final conversionFactor = this.measure!.weight! / measure.weight!;
    final amount = this.amount! * conversionFactor;
    return Quantity(amount: amount, measure: measure);
  }
}

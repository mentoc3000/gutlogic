import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../model_interfaces.dart';

part 'irritant.g.dart';

abstract class Irritant with Named implements Built<Irritant, IrritantBuilder>, Searchable {
  static Serializer<Irritant> get serializer => _$irritantSerializer;

  /// Concentration in g of irritant per g of food. Null indicates unknown concentration.
  double get concentration;

  /// Grams of irritant per serving of food. Null indicates unknown.
  double get dosePerServing;

  Irritant._();

  factory Irritant({required String name, required double concentration, required double dosePerServing}) =
      _$Irritant._;

  factory Irritant.fromBuilder([IrritantBuilder Function(IrritantBuilder) updates]) = _$Irritant;

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;

  bool isPresent() => concentration > 0;
}

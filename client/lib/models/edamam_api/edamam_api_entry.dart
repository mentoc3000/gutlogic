import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../util/null_utils.dart';
import '../food/edamam_food.dart';
import '../irritant.dart';
import '../measure.dart';
import './edamam_api_food.dart';
import './edamam_api_irritant.dart';
import './edamam_api_measure.dart';

part 'edamam_api_entry.g.dart';

abstract class EdamamApiEntry implements Built<EdamamApiEntry, EdamamApiEntryBuilder> {
  static Serializer<EdamamApiEntry> get serializer => _$edamamApiEntrySerializer;

  EdamamApiFood get food;
  BuiltList<EdamamApiMeasure> get measures;
  BuiltList<EdamamApiIrritant>? get irritants;

  EdamamApiEntry._();

  factory EdamamApiEntry([void Function(EdamamApiEntryBuilder) updates]) = _$EdamamApiEntry;

  EdamamFood? toEdamamFood() {
    if (food.foodId == null) return null;
    if (food.label == null) return null;

    final measures = <Measure>[];
    for (var nativeMeasure in this.measures) {
      if (!_isValidLabel(nativeMeasure.label)) continue;

      if (nativeMeasure.qualified == null) {
        if (_isValidWeight(nativeMeasure.weight)) {
          measures.add(Measure(unit: nativeMeasure.label!, weight: nativeMeasure.weight!));
        }
      } else {
        if (nativeMeasure.qualified == null) continue;

        for (var qualifiedMeasure in nativeMeasure.qualified!) {
          if (!_isValidWeight(qualifiedMeasure.weight)) continue;

          for (var qualifier in qualifiedMeasure.qualifiers!) {
            final unit =
                _isValidLabel(qualifier.label) ? '${nativeMeasure.label}, ${qualifier.label}' : nativeMeasure.label!;
            measures.add(Measure(unit: unit, weight: qualifiedMeasure.weight!));
          }
        }
      }
    }

    final irritants = this.irritants?.map((i) => i.toIrritant()).whereNotNull() ?? <Irritant>[];

    return EdamamFood(
        id: food.foodId!,
        name: food.label!,
        measures: measures.build(),
        brand: food.brand,
        irritants: irritants.toBuiltList());
  }
}

bool _isValidLabel(String? label) => label?.isNotEmpty ?? false;

bool _isValidWeight(num? weight) => weight != null && weight > 0;

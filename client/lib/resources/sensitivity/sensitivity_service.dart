import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity.dart';
import '../../resources/sensitivity/sensitivity_repository.dart';

class SensitivityService extends ChangeNotifier {
  final SensitivityRepository sensitivityRepository;

  final Map<FoodReference, Sensitivity> _cache = <FoodReference, Sensitivity>{};

  SensitivityService({required this.sensitivityRepository}) {
    sensitivityRepository.streamAll().listen(_cacheSensitivityEntries);
  }

  void _cacheSensitivityEntries(BuiltMap<FoodReference, Sensitivity> entries) {
    _cache.clear(); // TODO this would be improved by the repository streaming additions and deletions
    _cache.addAll(entries.toMap());

    notifyListeners();
  }

  Sensitivity of(FoodReference food) {
    return _cache[food] ?? Sensitivity.unknown;
  }

  Sensitivity aggregate(Iterable<FoodReference> foods) => Sensitivity.aggregate(foods.map(of));
}

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity.dart';
import '../../resources/sensitivity/sensitivity_repository.dart';
import '../../util/app_config.dart';
import '../irritant_service.dart';
import 'heuristic_sensitivity_prediction_service.dart';

class SensitivityService extends ChangeNotifier {
  final SensitivityRepository sensitivityRepository;
  final HeuristicSensitivityPredictionService? heuristicPredictionService;

  final Map<FoodReference, Sensitivity> _cache = <FoodReference, Sensitivity>{};

  SensitivityService({required this.sensitivityRepository, this.heuristicPredictionService}) {
    final sensitivityMapStream = sensitivityRepository.streamAll();
    sensitivityMapStream.listen(_cacheSensitivityEntries);
    heuristicPredictionService?.onChange(notifyListeners);
  }

  static SensitivityService fromContext(BuildContext context) {
    final sensitivityRepository = context.read<SensitivityRepository>();
    final heuristicPredictionService = context.read<AppConfig>().isDevelopment
        ? HeuristicSensitivityPredictionService(
            irritantService: context.read<IrritantService>(),
            sensitivityMapStream: sensitivityRepository.streamAll(),
          )
        : null;
    return SensitivityService(
      sensitivityRepository: sensitivityRepository,
      heuristicPredictionService: heuristicPredictionService,
    );
  }

  void _cacheSensitivityEntries(BuiltMap<FoodReference, Sensitivity> entries) {
    _cache.clear(); // TODO this would be improved by the repository streaming additions and deletions
    _cache.addAll(entries.toMap());

    notifyListeners();
  }

  Future<Sensitivity> of(FoodReference food) async {
    return _cache[food] ?? (await heuristicPredictionService?.predict(food)) ?? Sensitivity.unknown;
  }

  Future<Sensitivity> aggregate(Iterable<FoodReference> foods) async {
    final sensitivities = await Future.wait(foods.map(of));
    return Sensitivity.aggregate(sensitivities);
  }
}

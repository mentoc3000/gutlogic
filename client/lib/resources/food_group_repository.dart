import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:gutlogic/resources/api_service.dart';
import 'package:provider/provider.dart';

import '../models/food_group_entry.dart';
import '../models/serializers.dart';
import 'firebase/firestore_repository.dart';

typedef FoodGroups = BuiltMap<String, BuiltList<FoodGroupEntry>>;

class FoodGroupsRepository with FirestoreRepository {
  final ApiService apiService;
  BuiltMap<String, BuiltSet<FoodGroupEntry>>? _cache;

  FoodGroupsRepository({required this.apiService});

  static FoodGroupsRepository fromContext(BuildContext context) {
    return FoodGroupsRepository(apiService: context.read<ApiService>());
  }

  Future<BuiltMap<String, BuiltSet<FoodGroupEntry>>> _getCache() async {
    final res = await apiService.get(path: '/irritant/foodGroups');
    final data = res['data'] as Map<String, dynamic>;
    return BuiltMap<String, BuiltSet<FoodGroupEntry>>(
      data.map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map((e) => serializers.deserializeWith(FoodGroupEntry.serializer, e))
              .whereType<FoodGroupEntry>()
              .toBuiltSet(),
        ),
      ),
    );
  }

  Future<BuiltSet<String>> groups() async {
    _cache ??= await _getCache();
    return _cache!.keys.toBuiltSet();
  }

  /// Foods in the food group repository. If [group] is provided, only the foods in that group.
  Future<BuiltSet<FoodGroupEntry>> foods({String? group}) async {
    _cache ??= await _getCache();
    if (group != null) {
      return _cache![group] ?? BuiltSet();
    } else {
      return _cache!.values.expand((element) => element).toBuiltSet();
    }
  }
}

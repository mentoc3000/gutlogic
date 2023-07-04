import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/food_group_entry.dart';
import '../models/serializers.dart';
import 'cached_api_service.dart';
import 'firebase/firestore_repository.dart';

typedef FoodGroups = BuiltMap<String, BuiltList<FoodGroupEntry>>;

class FoodGroupsRepository with FirestoreRepository {
  final CachedApiService cachedApiService;
  BuiltMap<String, BuiltSet<FoodGroupEntry>>? _cache;

  FoodGroupsRepository({required this.cachedApiService});

  static FoodGroupsRepository fromContext(BuildContext context) {
    return FoodGroupsRepository(cachedApiService: context.read<CachedApiService>());
  }

  Future<BuiltMap<String, BuiltSet<FoodGroupEntry>>> _getCache() async {
    final res = await cachedApiService.get(path: '/irritant/foodGroups');
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

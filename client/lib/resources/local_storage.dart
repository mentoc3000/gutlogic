import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/food/edamam_food.dart';

class LocalStorage {
  late final LazyBox<String> _apiResponseCache;
  late final LazyBox<String> _edamamFoodCache;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _apiResponseCache = await Hive.openLazyBox('api_response_cache');
    _edamamFoodCache = await Hive.openLazyBox('edamam_food_cache');
  }

  void cacheApiResponse(String key, Object data) {
    unawaited(_apiResponseCache.put(key, jsonEncode(data)));
  }

  Future<Map<String, dynamic>?> getApiResponse(String key) async {
    final cachedData = await _apiResponseCache.get(key);
    if (cachedData != null) {
      return jsonDecode(cachedData) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  void cacheEdamamFood(EdamamFood food) {
    unawaited(_edamamFoodCache.put(food.id, jsonEncode(EdamamFood.serialize(food))));
  }

  Future<EdamamFood?> getEdamamFood(String id) async {
    final cachedData = await _edamamFoodCache.get(id);
    if (cachedData != null) {
      final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
      return EdamamFood.deserialize(decoded);
    } else {
      return null;
    }
  }
}

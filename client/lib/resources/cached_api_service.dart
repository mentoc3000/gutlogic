import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../resources/local_storage.dart';
import 'api_service.dart';

class CachedApiService {
  final ApiService apiService;
  final LocalStorage localStorage;

  CachedApiService({required this.apiService, required this.localStorage});

  static CachedApiService fromContext(BuildContext context) {
    return CachedApiService(
      apiService: context.read<ApiService>(),
      localStorage: context.read<LocalStorage>(),
    );
  }

  Future<Map<String, dynamic>> get({
    required String path,
    Map<String, dynamic>? params,
    bool fallbackToLocal = false,
  }) async {
    late final Map<String, dynamic> data;
    try {
      data = await apiService.get(path: path);
      localStorage.cacheApiResponse(path, data);
    } catch (e) {
      final storedData = await localStorage.getApiResponse(path);
      if (storedData != null) {
        data = storedData;
      } else {
        rethrow;
      }
    }
    return data;
  }
}

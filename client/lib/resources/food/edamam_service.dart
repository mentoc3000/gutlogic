import '../../models/food/edamam_food.dart';
import '../../models/serializers.dart';
import '../../util/null_utils.dart';
import '../api_service.dart';

class EdamamService {
  final ApiService apiService;

  EdamamService({required this.apiService});

  /// Search for food on Edamam
  ///
  /// Empty query returns no results
  Future<List<EdamamFood>> searchFood(String query) async {
    if (query.isEmpty) return [];

    late final Map<String, dynamic> response;

    try {
      response = await apiService.get(path: '/food/v0/search', params: {'name': query});
    } catch (e) {
      if (e is HttpException) {
        if (e.statusCode == 404 || e.statusCode == 443) return [];
        if (e.statusCode == 401) throw EdamamException(message: 'API authentication error');
      }
      throw EdamamException(message: 'Something is wrong with Edamam');
    }

    try {
      final entries = response['data'] as List;
      return entries.map((e) => serializers.deserializeWith(EdamamFood.serializer, e)).whereNotNull().toList();
    } catch (e) {
      throw EdamamException(message: 'Parsing error');
    }
  }

  /// Get Edamam food by Id
  ///
  /// No match returns null.
  Future<EdamamFood?> getById(String id) async {
    if (id.isEmpty) return null;

    late final Map<String, dynamic> response;

    try {
      response = await apiService.get(path: '/food/v0/$id');
    } catch (e) {
      if (e is HttpException) {
        if (e.statusCode == 404 || e.statusCode == 443) return null;
      } else {
        throw EdamamException(message: 'Something is wrong with Edamam');
      }
    }

    try {
      final entry = response['data'] as Map?;
      return entry != null ? serializers.deserializeWith(EdamamFood.serializer, entry) : null;
    } catch (e) {
      throw EdamamException(message: 'Parsing error');
    }
  }
}

class EdamamException implements Exception {
  final String message;

  EdamamException({required this.message});
}

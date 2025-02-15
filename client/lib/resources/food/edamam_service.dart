import '../../models/food/edamam_food.dart';
import '../../models/serializers.dart';
import '../../util/logger.dart';
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

    final response = await apiService.get(path: '/food/v0/search', params: {'name': query});

    try {
      final entries = response['data'] as List;
      return entries
          .map((entry) {
            try {
              return serializers.deserializeWith(EdamamFood.serializer, entry);
            } catch (e) {
              logger.w('Error parsing entry $entry');
            }
          })
          .whereNotNull()
          .toList();
    } catch (e) {
      throw EdamamException(message: 'Parsing error');
    }
  }

  /// Get Edamam food by Id
  ///
  /// No match returns null.
  Future<EdamamFood?> getById(String id) async {
    if (id.isEmpty) return null;

    final response = await apiService.get(path: '/food/v0/$id');

    try {
      final entry = response['data'] as Map?;
      return entry != null ? serializers.deserializeWith(EdamamFood.serializer, entry) : null;
    } catch (e) {
      throw EdamamException(message: 'Parsing error');
    }
  }

  /// Get Edamam food by UPC
  ///
  /// No match returns null.
  Future<EdamamFood?> getByUpc(String upc) async {
    if (upc.isEmpty) return null;

    final response = await apiService.get(path: '/food/v0/upc/$upc');

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

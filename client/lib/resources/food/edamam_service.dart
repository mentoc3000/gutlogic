import '../../models/edamam_api/edamam_api_entry.dart';
import '../../models/serializers.dart';
import '../../util/null_utils.dart';
import '../firebase/cloud_function_service.dart';

class EdamamService {
  final CloudFunction edamamFoodSearchFunction;

  EdamamService({required CloudFunctionService cloudFunctionService})
      : edamamFoodSearchFunction = cloudFunctionService.function('edamamFoodSearch');

  /// Search for food on Edamam
  ///
  /// Empty query returns no results
  Future<List<EdamamApiEntry>> searchFood(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final response = await edamamFoodSearchFunction.call({'query': query});
    switch (response['status']) {
      case 200:
        try {
          final entries = response['data']['hints'] as List;
          return entries.map((e) => serializers.deserializeWith(EdamamApiEntry.serializer, e)).whereNotNull().toList();
        } catch (e) {
          throw EdamamException(message: 'Parsing error');
        }
      case 404:
        return [];
      case 443:
        return [];
    }
    throw EdamamException(message: 'Something is wrong with Edamam');
  }

  /// Get Edamam food by Id
  ///
  /// No match returns null.
  Future<EdamamApiEntry?> getById(String id) async {
    final searchResults = await searchFood(id);
    return searchResults.isNotEmpty ? searchResults[0] : null;
  }
}

class EdamamException implements Exception {
  final String message;

  EdamamException({required this.message});
}

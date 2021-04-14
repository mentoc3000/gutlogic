import 'package:meta/meta.dart';

import '../../models/edamam_api/edamam_api_entry.dart';
import '../../models/serializers.dart';

import '../firebase/cloud_function_service.dart';

class EdamamService {
  CloudFunctionService edamamFoodSearchService;

  EdamamService({@required this.edamamFoodSearchService});

  /// Search for food on Edamam
  ///
  /// Empty query returns no results
  Future<List<EdamamApiEntry>> searchFood(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final response = await edamamFoodSearchService.callWith({'query': query});
    switch (response['status']) {
      case 200:
        try {
          final jsonResponse = response['data'];
          final List<dynamic> entries = jsonResponse['hints'];
          return entries.map((e) => serializers.deserializeWith(EdamamApiEntry.serializer, e)).toList();
        } catch (e) {
          throw EdamamException(message: 'Parsing error');
        }
        break;
      case 443:
        return [];
    }
    throw EdamamException(message: 'Something is wrong with Edamam');
  }

  /// Get Edamam food by Id
  ///
  /// No match returns null.
  Future<EdamamApiEntry> getById(String id) async {
    final searchResults = await searchFood(id);
    if (searchResults.isEmpty) {
      return null;
    }
    return searchResults[0];
  }
}

class EdamamException implements Exception {
  final String message;

  EdamamException({@required this.message});
}

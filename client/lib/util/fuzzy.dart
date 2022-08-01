import 'package:edit_distance/edit_distance.dart';
import 'package:collection/collection.dart';

final NormalizedStringDistance _similarityEngine = JaroWinkler();

/// The number of discrete bins used for comparison
const _resolution = 1000;

/// Similarity threshold above which the result is removed
const _threshold = 0.9;

int _similarityCompare(String a, String b) {
  a = a.toLowerCase();
  b = b.toLowerCase();
  if (a.isEmpty || b.isEmpty) return _resolution;
  final distance = _similarityEngine.normalizedDistance(a, b);
  return (_resolution * distance).floor();
}

List<T> stringSimilaritySort<T>({required List<T> list, required String match, required String Function(T) keyOf}) {
  return list.sortedByCompare(
      keyOf, (String a, String b) => _similarityCompare(a, match).compareTo(_similarityCompare(b, match)))
    ..removeWhere(
        (e) => _similarityEngine.normalizedDistance(keyOf(e).toLowerCase(), match.toLowerCase()) > _threshold);
}

extension IterableExtensions<T> on Iterable<T> {
  /// Returns true if all of the elements pass the predicate.
  bool all(bool Function(T element) test) {
    return any((e) => test(e) == false) == false;
  }
}

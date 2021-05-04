extension IterableExtentions<T> on Iterable<T?> {
  /// Filters null values from an iterable and casts to a non-null iterable.
  Iterable<T> whereNotNull() => where(isNotNull).cast<T>();
}

/// Do a dynamic null check.
bool isNotNull(dynamic? value) => value != null;

extension IterableNullExtension<T> on Iterable<T?> {
  /// Filters null values from an iterable and casts to a non-null iterable.
  Iterable<T> whereNotNull() => whereType<T>();
}

extension StreamNullExtension<T> on Stream<T?> {
  /// Filters null values from a stream and casts to a non-null stream.
  Stream<T> whereNotNull() => where(isNotNull).cast<T>();
}

/// Do a dynamic null check.
bool isNotNull(dynamic value) => value != null;

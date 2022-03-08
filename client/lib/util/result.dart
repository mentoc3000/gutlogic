/// A union type of either a value or error.
class Result<T> {
  final T? value;
  final Object? error;

  final bool isValue;

  bool get isError => isValue == false;

  Result.value(this.value)
      : error = null,
        isValue = true;

  Result.error(this.error)
      : value = null,
        isValue = false;
}

/// An alias for a generic future result.
typedef FutureResult<T> = Future<Result<T>>;

/// Execute [func] with the value of [result] if the result is not an error result.
void maybe<T>(Result<T> result, void Function(T) func) {
  if (result.isValue) func(result.value!);
}

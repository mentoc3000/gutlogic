import 'dart:async';

extension StreamExtensions<T> on Stream<T> {
  /// Returns a future that completes with the next value emitted from the stream.
  Future<T> next() {
    final completer = Completer<T>();

    late final StreamSubscription subscription;

    subscription = listen((data) {
      completer.complete(data);
      subscription.cancel();
    }, onError: (dynamic error, StackTrace trace) {
      completer.completeError(error, trace);
      subscription.cancel();
    }, onDone: () {
      completer.completeError('The stream was closed.');
      subscription.cancel();
    });

    return completer.future;
  }
}

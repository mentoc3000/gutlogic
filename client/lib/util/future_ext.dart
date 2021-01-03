typedef FutureProducer<T> = Future<T> Function();

abstract class FutureExt {
  /// Run a list of futures with limited [concurrency].
  static Future<List<T>> pool<T>(Iterable<FutureProducer<T>> producers, {int concurrency = 2}) async {
    assert(concurrency > 0, 'Future pool concurrency must be greater than 0.');

    final result = List<T>(producers.length);
    final queue = producers.toList();

    var sharedQueueIndex = 0;

    Future<void> runner() async {
      while (sharedQueueIndex < queue.length) {
        final runnerQueueIndex = sharedQueueIndex++;

        try {
          result[runnerQueueIndex] = await queue[runnerQueueIndex]();
        } catch (ex) {
          result[runnerQueueIndex] = ex;
        }
      }
    }

    await Future.wait(List.generate(concurrency, (index) => runner()));

    return result;
  }
}

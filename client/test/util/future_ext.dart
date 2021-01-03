import 'package:gutlogic/util/future_ext.dart';
import 'package:test/test.dart';

void main() {
  group('FutureExt', () {
    test('pool generates value list in order', () async {
      final producers = [
        () => Future.delayed(const Duration(milliseconds: 10), () => 0),
        () => Future.value(1),
        () => Future.value(2),
        () => Future.value(3),
        () => Future.value(4),
        () => Future.value(5),
      ];

      expect(await FutureExt.pool(producers), equals([0, 1, 2, 3, 4, 5]));
    });

    test('pool limits concurrency', () async {
      const concurrency = 2;

      var counter = 0;

      Future<void> assertion(int index, int delay) async {
        expect(counter++, lessThanOrEqualTo(concurrency));
        await Future.delayed(Duration(seconds: delay));
        expect(counter--, lessThanOrEqualTo(concurrency));
      }

      final producers = [
        () => assertion(0, 50),
        () => assertion(1, 10),
        () => assertion(2, 10),
        () => assertion(3, 10),
        () => assertion(4, 10),
        () => assertion(5, 10),
      ];

      await FutureExt.pool(producers, concurrency: concurrency);
    });
  });
}

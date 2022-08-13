import 'package:gutlogic/util/fuzzy.dart';
import 'package:test/test.dart';
import 'package:equatable/equatable.dart';

class Foo extends Equatable {
  final String s;

  const Foo(this.s);

  @override
  String toString() => 'Foo($s)';

  @override
  List<Object> get props => [s];
}

void approxEquals(num actual, num expected, [num? tolerance]) {
  tolerance ??= (expected / 1e4).abs();
  // Note: use !( <= ) rather than > so we fail on NaNs
  if ((expected - actual).abs() <= tolerance) return;

  fail('Expect.approxEquals(expected:<$expected>, actual:<$actual>, '
      'tolerance:<$tolerance>) fails');
}

void main() {
  group('Fuzzy', () {
    group('similarity by string', () {
      test('of empty list', () {
        const list = <Foo>[];
        expect(stringSimilaritySort(list: list, match: 's', keyOf: (Foo p0) => p0.s), list);
      });
      test('of dissimilar words', () {
        const list = [Foo('tab'), Foo('F7')];
        expect(stringSimilaritySort(list: list, match: 's', keyOf: (Foo p0) => p0.s), <Foo>[]);
      });
      test('to empty string', () {
        const list = [Foo('tab'), Foo('F7')];
        expect(stringSimilaritySort(list: list, match: '', keyOf: (Foo p0) => p0.s), <Foo>[]);
      });
      test('sorts by similarity', () {
        const list = [Foo('spacebar'), Foo('F7'), Foo('space')];
        expect(stringSimilaritySort(list: list, match: 'space', keyOf: (Foo p0) => p0.s),
            const <Foo>[Foo('space'), Foo('spacebar')]);
      });
      test('ignores case', () {
        const list = [Foo('F5'), Foo('Space'), Foo('f')];
        expect(stringSimilaritySort(list: list, match: 'f', keyOf: (Foo p0) => p0.s), const <Foo>[Foo('f'), Foo('F5')]);
      });
    });

    group('matches by string', () {
      test('of empty list', () {
        const list = <Foo>[];
        expect(stringMatchSort(list: list, match: 's', keyOf: (Foo p0) => p0.s), list);
      });
      test('of dissimilar words', () {
        const list = [Foo('tab'), Foo('F7')];
        expect(stringMatchSort(list: list, match: 's', keyOf: (Foo p0) => p0.s), <Foo>[]);
      });
      test('to empty string', () {
        const list = [Foo('tab'), Foo('F7')];
        expect(stringMatchSort(list: list, match: '', keyOf: (Foo p0) => p0.s), <Foo>[]);
      });
      test('sorts by similarity', () {
        const list = [Foo('spacebar'), Foo('putty'), Foo('science')];
        expect(stringMatchSort(list: list, match: 'p', keyOf: (Foo p0) => p0.s),
            const <Foo>[Foo('putty'), Foo('spacebar')]);
      });
      test('ignores case', () {
        const list = [Foo('F5'), Foo('Space'), Foo('f7')];
        expect(stringMatchSort(list: list, match: 'f', keyOf: (Foo p0) => p0.s), const <Foo>[Foo('F5'), Foo('f7')]);
      });
      test('shorter matches first', () {
        const list = [Foo('F5'), Foo('Space'), Foo('f')];
        expect(stringMatchSort(list: list, match: 'f', keyOf: (Foo p0) => p0.s), const <Foo>[Foo('f'), Foo('F5')]);
      });
    });
  });
}

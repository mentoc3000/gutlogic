import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:test/test.dart';

class Foo extends Equatable {
  final int x;

  Foo(this.x);

  @override
  List<Object> get props => [x];

  @override
  String toString() => 'Foo($x)';
}

class Bar extends Equatable with DebouncedEvent {
  final int x;

  Bar(this.x);

  @override
  List<Object> get props => [x];

  @override
  String toString() => 'Bar($x)';
}

class Baz extends Equatable with DebouncedEvent {
  final int x;

  Baz(this.x);

  @override
  List<Object> get props => [x];

  @override
  String toString() => 'Baz($x)';
}

abstract class PairEvent {}

class SetFirstEvent extends PairEvent with DebouncedEvent {
  final int first;
  SetFirstEvent(this.first);
}

class SetSecondEvent extends PairEvent with DebouncedEvent {
  final int second;
  SetSecondEvent(this.second);
}

class Pair extends Equatable {
  final int first;
  final int second;

  Pair(this.first, this.second);

  Pair setFirst(int x) => Pair(x, second);
  Pair setSecond(int x) => Pair(first, x);

  @override
  List<Object> get props => [first, second];

  @override
  String toString() => '($first, $second)';
}

class PairBloc extends Bloc<PairEvent, Pair> {
  PairBloc() : super(Pair(0, 0));

  @override
  Stream<Transition<PairEvent, Pair>> transformEvents(
    Stream<PairEvent> events,
    TransitionFunction<PairEvent, Pair> transition,
  ) {
    final debouncedStream = debounceDebouncedByType(events);
    return super.transformEvents(debouncedStream, transition);
  }

  @override
  Stream<Pair> mapEventToState(
    PairEvent event,
  ) async* {
    if (event is SetFirstEvent) {
      yield state.setFirst(event.first);
    }
    if (event is SetSecondEvent) {
      yield state.setSecond(event.second);
    }
  }
}

void main() {
  group('Bloc helpers', () {
    group('debounce', () {
      test('all events', () async {
        final stream = Stream.fromIterable([Foo(0), Bar(1), Baz(2), Foo(3), Bar(4), Baz(5)]);
        final debouncedStream = debounceAll(stream);
        expect(debouncedStream.isBroadcast, false);
        await expectLater(debouncedStream, emitsInOrder([Baz(5), emitsDone]));
      });

      test('all events by type', () async {
        final stream = Stream.fromIterable([Foo(0), Bar(1), Baz(2), Foo(3), Bar(4), Baz(5)]);
        final debouncedStream = debounceAllByType(stream);
        expect(debouncedStream.isBroadcast, false);
        await expectLater(debouncedStream, emitsInOrder([Foo(3), Bar(4), Baz(5), emitsDone]));
      });

      test('all debounced events', () async {
        final stream = Stream.fromIterable([Foo(0), Bar(1), Baz(2), Foo(3), Bar(4), Baz(5)]).asBroadcastStream();
        final debouncedStream = debounceAllDebounced(stream);
        expect(debouncedStream.isBroadcast, false);
        await expectLater(debouncedStream, emitsInOrder([Foo(0), Foo(3), Baz(5), emitsDone]));
      });

      test('all debounced events by type', () async {
        final stream = Stream.fromIterable([Foo(0), Bar(1), Baz(2), Foo(3), Bar(4), Baz(5)]).asBroadcastStream();
        final debouncedStream = debounceDebouncedByType(stream);
        expect(debouncedStream.isBroadcast, false);
        await expectLater(debouncedStream, emitsInOrder([Foo(0), Foo(3), Bar(4), Baz(5), emitsDone]));
      });

      blocTest(
        'bloc events separately',
        build: () async => PairBloc(),
        act: (bloc) async =>
            bloc..add(SetFirstEvent(5))..add(SetSecondEvent(5))..add(SetFirstEvent(3))..add(SetSecondEvent(3)),
        wait: const Duration(seconds: 2),
        expect: [Pair(3, 0), Pair(3, 3)],
      );
    });
  });
}

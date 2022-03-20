import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:test/test.dart';

abstract class PairEvent {}

class SetFirstEvent extends PairEvent {
  final int first;
  SetFirstEvent(this.first);
}

class SetSecondEvent extends PairEvent {
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
  PairBloc() : super(Pair(0, 0)) {
    on<SetFirstEvent>(_onSetFirst, transformer: debounceTransformer);
    on<SetSecondEvent>(_onSetSecond, transformer: debounceTransformer);
  }

  void _onSetFirst(SetFirstEvent event, Emitter<Pair> emit) {
    emit(state.setFirst(event.first));
  }

  void _onSetSecond(SetSecondEvent event, Emitter<Pair> emit) {
    emit(state.setSecond(event.second));
  }
}

void main() {
  group('Bloc helpers', () {
    group('debounce', () {
      blocTest<PairBloc, Pair>(
        'bloc events separately',
        build: () => PairBloc(),
        act: (bloc) async {
          return bloc
            ..add(SetFirstEvent(5))
            ..add(SetSecondEvent(5))
            ..add(SetFirstEvent(3))
            ..add(SetSecondEvent(3));
        },
        wait: const Duration(seconds: 2),
        expect: () => [Pair(3, 0), Pair(3, 3)],
      );
    });
  });
}

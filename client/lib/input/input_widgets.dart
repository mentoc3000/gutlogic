import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'input.dart';
import 'input_group.dart';
import 'input_types.dart';

/// Rebuilds when a form field emits a new state (either value or error).
class InputBuilder<T> extends StatelessWidget {
  final Input<T> input;
  final Widget Function(BuildContext context, InputState<T> state) builder;

  InputBuilder({Key? key, required this.input, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Input<T>, InputState<T>>(
      bloc: input,
      builder: builder,
    );
  }
}

/// Rebuilds when a field emits a new value.
class InputValueBuilder<T> extends StatelessWidget {
  final Input<T> input;
  final Widget Function(BuildContext context, T value) builder;

  InputValueBuilder({Key? key, required this.input, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Input<T>, InputState<T>>(
      bloc: input,
      buildWhen: (prev, next) => prev.value != next.value, // ignore errors
      builder: (context, state) => builder(context, state.value),
    );
  }
}

/// Rebuilds when a field emits a new error.
class InputErrorBuilder<T> extends StatelessWidget {
  final Input<T> input;
  final Widget Function(BuildContext context, String? error) builder;

  InputErrorBuilder({
    Key? key,
    required this.input,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Input, InputState>(
      bloc: input,
      buildWhen: (prev, next) => prev.error != next.error, // ignore values
      builder: (context, state) => builder(context, state.error),
    );
  }
}

/// Rebuilds when a form state changes.
class InputGroupBuilder<T extends InputGroup> extends StatelessWidget {
  final Widget Function(BuildContext context, InputGroupState state) builder;

  InputGroupBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<T, InputGroupState>(builder: builder);
}

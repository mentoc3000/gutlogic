import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A function which validates a [T] value and returns an error string if the value is invalid, or null if valid.
typedef InputValidator<T> = String? Function(T value);

/// An encapsulated value and error state for a single input.
class InputState<T> extends Equatable {
  /// The current value.
  final T value;

  /// The validation error message, if any.
  final String? error;

  /// True if the value has been changed from the default value.
  final bool dirty;

  /// True if the value is valid.
  bool get valid => error == null;

  const InputState({
    required this.value,
    required this.dirty,
    this.error,
  });

  @override
  List<Object?> get props => [value, error, dirty];
}

/// A stream of input states that performs validation when the value changes.
class Input<T> extends Cubit<InputState<T>> {
  /// The field validator, or null if one was not provided.
  InputValidator<T>? validator;

  /// The current state input value.
  T get value => state.value;

  /// The current state error value.
  String? get error => state.error;

  /// The current state valid value.
  bool get valid => state.valid;

  /// The current state dirty value.
  bool get dirty => state.dirty;

  /// Creates a new field with a default value.
  Input(T value, [this.validator])
      : super(InputState(
          value: value,
          error: validator?.call(value),
          dirty: false,
        ));

  /// Replace the value, which also validates the field and emits a new state.
  void set(T value) {
    if (value != state.value) {
      emit(InputState(
        value: value,
        error: validator?.call(value),
        dirty: true,
      ));
    }
  }
}

/// A special input string that maintains a TextEditingController.
class InputText extends Input<String> {
  final TextEditingController controller;

  InputText({String value = '', InputValidator<String>? validator})
      : controller = TextEditingController(text: value),
        super(value, validator) {
    controller.addListener(() => set(controller.text));
  }

  @override
  Future<void> close() async {
    controller.dispose();
    await super.close();
  }
}

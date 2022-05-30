import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'input.dart';
import 'input_types.dart';

class InputGroupState extends Equatable {
  /// True if any of the inputs are dirty.
  final bool dirty;

  /// True if all of the inputs are valid.
  final bool valid;

  const InputGroupState({required this.dirty, required this.valid});

  @override
  List<Object?> get props => [dirty, valid];
}

/// A base class for forms that automatically emits a validation state whenever any of its values change.
abstract class InputGroup extends Cubit<InputGroupState> {
  InputGroup() : super(const InputGroupState(dirty: false, valid: false)) {
    for (final input in inputs) {
      input.stream.listen(_onInputChanged);
    }

    update(); // update initial state now that we can access inputs field
  }

  @override
  Future<void> close() async {
    await Future.wait(inputs.map((i) => i.close()));
    await super.close();
  }

  /// The current state dirty value.
  bool get dirty => state.dirty;

  /// The current state valid value.
  bool get valid => state.valid;

  /// Overridden by form subclasses so this class can operate on them.
  List<Input<dynamic>> get inputs;

  /// Update the cubit state with the latest input values.
  void update() {
    var dirty = false;
    var valid = true;

    for (var input in inputs) {
      dirty = dirty || input.dirty;
      valid = valid && input.valid;
    }

    emit(InputGroupState(dirty: dirty, valid: valid));
  }

  /// Updates the form state whenever a form value changes.
  void _onInputChanged(_) => update();
}

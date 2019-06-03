import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/medicine.dart';

@immutable
abstract class MedicinesState extends Equatable {
  MedicinesState([List props = const []]) : super(props);
}

class InitialMedicineState extends MedicinesState {}

class MedicinesUninitialized extends MedicinesState {
  @override
  String toString() => 'MedicinesUninitialized';
}

class MedicinesError extends MedicinesState {
  @override
  String toString() => 'MedicinesError';
}

class MedicinesLoaded extends MedicinesState {
  final List<Medicine> medicines;

  MedicinesLoaded({
    this.medicines,
  }) : super([medicines]);

  MedicinesLoaded copyWith({
    List<Medicine> medicines,
  }) {
    return MedicinesLoaded(
      medicines: medicines ?? this.medicines,
    );
  }

  @override
  String toString() => 'MedicinesLoaded { medicines: ${medicines.length} }';
}

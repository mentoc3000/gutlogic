import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MedicinesEvent extends Equatable {
  MedicinesEvent([List props = const []]) : super(props);
}

class Fetch extends MedicinesEvent {
  @override
  String toString() => 'Fetch';
}
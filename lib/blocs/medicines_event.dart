import 'package:equatable/equatable.dart';

abstract class MedicinesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Fetch extends MedicinesEvent {
  @override
  String toString() => 'Fetch';
}
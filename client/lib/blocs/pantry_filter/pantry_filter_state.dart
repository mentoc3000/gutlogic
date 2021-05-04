import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/pantry/pantry_entry.dart';
import '../../models/pantry/pantry_filter.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class PantryFilterState extends Equatable {
  const PantryFilterState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

mixin Filter {
  PantryFilter get filter;
}

class PantryFilterLoading extends PantryFilterState with Filter, SearchableLoading {
  @override
  final PantryFilter filter;

  PantryFilterLoading({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class PantryFilterLoaded extends PantryFilterState with Filter, SearchableLoaded {
  @override
  final BuiltList<PantryEntry> items;

  @override
  final PantryFilter filter;

  PantryFilterLoaded({required this.items, required this.filter});

  @override
  List<Object?> get props => [items, filter];
}

class PantryFilterError extends PantryFilterState with ErrorState {
  @override
  final String message;

  PantryFilterError({required this.message});

  factory PantryFilterError.from(ErrorState errorState) => PantryFilterError(message: errorState.message);
}

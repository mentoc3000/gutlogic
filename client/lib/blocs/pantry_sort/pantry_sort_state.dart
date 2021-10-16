import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/pantry/pantry_entry.dart';
import '../../models/pantry/pantry_sort.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class PantrySortState extends Equatable {
  final PantrySort sort;

  const PantrySortState({required this.sort});

  @override
  List<Object?> get props => [sort];

  @override
  bool get stringify => true;
}

class PantrySortLoading extends PantrySortState with SearchableLoading {
  PantrySortLoading({required PantrySort sort}) : super(sort: sort);
}

class PantrySortLoaded extends PantrySortState with SearchableLoaded {
  @override
  final BuiltList<PantryEntry> items;

  PantrySortLoaded({required this.items, required PantrySort sort}) : super(sort: sort);

  @override
  List<Object?> get props => [items, sort];
}

class PantrySortError extends PantrySortState with ErrorState {
  @override
  final String? message;

  PantrySortError({required this.message, required PantrySort sort}) : super(sort: sort);

  factory PantrySortError.from({required ErrorState errorState, required PantrySort sort}) =>
      PantrySortError(message: errorState.message, sort: sort);

  @override
  List<Object?> get props => [message, sort];
}

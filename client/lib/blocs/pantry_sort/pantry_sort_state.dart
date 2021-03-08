import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/pantry_entry.dart';
import '../../models/pantry_sort.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class PantrySortState extends Equatable {
  const PantrySortState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

mixin CurrentSort {
  PantrySort get currentSort;
}

class PantrySortLoading extends PantrySortState with CurrentSort, SearchableLoading {
  @override
  final PantrySort currentSort;

  PantrySortLoading({@required this.currentSort});

  @override
  List<Object> get props => [currentSort];
}

class PantrySortLoaded extends PantrySortState with CurrentSort, SearchableLoaded {
  @override
  final BuiltList<PantryEntry> items;

  @override
  final PantrySort currentSort;

  PantrySortLoaded({this.items, this.currentSort});
}

class PantrySortError extends PantrySortState with ErrorState {
  @override
  final String message;

  PantrySortError({@required this.message});

  factory PantrySortError.from(ErrorState errorState) => PantrySortError(message: errorState.message);
}

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/pantry/pantry_entry.dart';
import '../../models/pantry/pantry_sort.dart';
import '../bloc_helpers.dart';
import '../pantry_filter/pantry_filter.dart';
import 'pantry_sort_state.dart';

const _defaultSort = PantrySort.alphabeticalAscending;

class PantrySortCubit extends Cubit<PantrySortState> with StreamSubscriber<PantryFilterState, PantrySortState> {
  final PantryFilterCubit pantryFilterCubit;
  PantrySort get _sort => state.sort;

  PantrySortCubit({required this.pantryFilterCubit})
      : super(
          pantryFilterCubit.state is PantryFilterLoaded
              ? PantrySortLoaded(
                  items: _sortPantry((pantryFilterCubit.state as PantryFilterLoaded).items, _defaultSort),
                  sort: _defaultSort)
              : PantrySortLoading(sort: _defaultSort),
        ) {
    streamSubscription = pantryFilterCubit.stream.listen((state) {
      if (state is PantryFilterLoading) {
        emit(PantrySortLoading(sort: _sort));
      } else if (state is PantryFilterLoaded) {
        final sortedItems = _sortPantry(state.items, _sort);
        emit(PantrySortLoaded(items: sortedItems, sort: _sort));
      } else if (state is PantryFilterError) {
        emit(PantrySortError.from(errorState: state, sort: _sort));
      }
    });
  }

  static PantrySortCubit fromContext(BuildContext context) {
    return PantrySortCubit(pantryFilterCubit: context.read<PantryFilterCubit>());
  }

  void sortBy(PantrySort pantrySort) {
    if (state is PantrySortLoaded) {
      final items = (state as PantrySortLoaded).items;
      final sortedItems = _sortPantry(items, pantrySort);
      emit(PantrySortLoaded(items: sortedItems, sort: pantrySort));
    } else if (state is PantrySortLoading) {
      emit(PantrySortLoading(sort: pantrySort));
    }
  }
}

int _compareAlphabetically(PantryEntry a, PantryEntry b) {
  return a.foodReference.name.toLowerCase().compareTo(b.foodReference.name.toLowerCase());
}

int _compareSensitivity(PantryEntry a, PantryEntry b) => a.sensitivity.level.compareTo(b.sensitivity.level);

BuiltList<PantryEntry> _sortAlphabeticallyAscending(BuiltList<PantryEntry> pantryEntries) {
  final list = pantryEntries.toList();
  list.sort(_compareAlphabetically);
  return list.toBuiltList();
}

BuiltList<PantryEntry> _sortBySensitivityAscending(BuiltList<PantryEntry> pantryEntries) {
  final list = pantryEntries.toList();
  list.sort(_compareAlphabetically);
  list.sort(_compareSensitivity);
  return list.toBuiltList();
}

BuiltList<PantryEntry> _sortBySensitivityDescending(BuiltList<PantryEntry> pantryEntries) {
  final list = pantryEntries.toList();
  list.sort((a, b) => _compareAlphabetically(b, a)); // Reverse alphabetical order
  list.sort(_compareSensitivity);
  return list.reversed.toBuiltList();
}

BuiltList<PantryEntry> _sortPantry(BuiltList<PantryEntry> pantryEntries, PantrySort pantrySort) {
  switch (pantrySort) {
    case PantrySort.alphabeticalAscending:
      return _sortAlphabeticallyAscending(pantryEntries);
    case PantrySort.sensitivityAscending:
      return _sortBySensitivityAscending(pantryEntries);
    case PantrySort.sensitivityDescending:
      return _sortBySensitivityDescending(pantryEntries);
    default:
      return _sortAlphabeticallyAscending(pantryEntries);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/pantry_entry.dart';
import '../../models/pantry_sort.dart';
import '../bloc_helpers.dart';
import '../pantry_filter/pantry_filter.dart';
import 'pantry_sort_state.dart';

const _defaultSort = PantrySort.alphabeticalAscending;

class PantrySortCubit extends Cubit<PantrySortState> with StreamSubscriber {
  final PantryFilterCubit pantryFilterCubit;
  PantrySort get _currentSort => state is CurrentSort ? (state as CurrentSort).currentSort : _defaultSort;

  PantrySortCubit({@required this.pantryFilterCubit})
      : super(
          pantryFilterCubit.state is PantryFilterLoaded
              ? PantrySortLoaded(
                  items: _sortPantry((pantryFilterCubit.state as PantryFilterLoaded).items, _defaultSort),
                  currentSort: _defaultSort)
              : PantrySortLoading(currentSort: _defaultSort),
        ) {
    streamSubscription = pantryFilterCubit.listen((state) {
      if (state is PantryFilterLoading) {
        emit(PantrySortLoading(currentSort: _currentSort));
      } else if (state is PantryFilterLoaded) {
        final sortedItems = _sortPantry(state.items, _currentSort);
        emit(PantrySortLoaded(items: sortedItems, currentSort: _currentSort));
      } else if (state is PantryFilterError) {
        emit(PantrySortError.from(state));
      }
    });
  }

  factory PantrySortCubit.fromContext(BuildContext context) {
    return PantrySortCubit(
      pantryFilterCubit: context.read<PantryFilterCubit>(),
    );
  }

  void sortBy(PantrySort pantrySort) {
    if (state is PantrySortLoaded) {
      final items = (state as PantrySortLoaded).items;
      final sortedItems = _sortPantry(items, pantrySort);
      emit(PantrySortLoaded(items: sortedItems, currentSort: pantrySort));
    } else if (state is PantrySortLoading) {
      emit(PantrySortLoading(currentSort: pantrySort));
    }
  }
}

int _compareAlphabetically(PantryEntry a, PantryEntry b) =>
    a.foodReference.name.toLowerCase().compareTo(b.foodReference.name.toLowerCase());

int _compareSensitivity(PantryEntry a, PantryEntry b) => a.sensitivity.compareTo(b.sensitivity);

BuiltList<PantryEntry> _sortAlphabeticallyAscending(BuiltList<PantryEntry> pantryEntries) {
  final list = pantryEntries.toList();
  list.sort(_compareAlphabetically);
  return list.build();
}

BuiltList<PantryEntry> _sortBySensitivityAscending(BuiltList<PantryEntry> pantryEntries) {
  final list = pantryEntries.toList();
  list.sort(_compareAlphabetically);
  list.sort(_compareSensitivity);
  return list.build();
}

BuiltList<PantryEntry> _sortPantry(BuiltList<PantryEntry> pantryEntries, PantrySort pantrySort) {
  switch (pantrySort) {
    case PantrySort.alphabeticalAscending:
      return _sortAlphabeticallyAscending(pantryEntries);
    case PantrySort.sensitivityAscending:
      return _sortBySensitivityAscending(pantryEntries);
    case PantrySort.sensitivityDescending:
      return _sortBySensitivityAscending(pantryEntries).reversed.toBuiltList();
    default:
      return _sortAlphabeticallyAscending(pantryEntries);
  }
}

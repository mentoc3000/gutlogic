import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/pantry/pantry_entry.dart';
import '../../models/pantry/pantry_filter.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../bloc_helpers.dart';
import '../pantry/pantry.dart';
import 'pantry_filter_state.dart';

final _defaultFilter = PantryFilter.all();

class PantryFilterCubit extends Cubit<PantryFilterState> with StreamSubscriber {
  final PantryBloc pantryBloc;
  PantryFilter get _filter => state is Filter ? (state as Filter).filter : _defaultFilter;

  PantryFilterCubit({required this.pantryBloc})
      : super(
          pantryBloc.state is PantryLoaded
              ? PantryFilterLoaded(
                  items: (pantryBloc.state as PantryLoaded).items,
                  filter: _defaultFilter,
                )
              : PantryFilterLoading(filter: _defaultFilter),
        ) {
    streamSubscription = pantryBloc.stream.listen((state) => _updateFilter(_filter));
  }

  factory PantryFilterCubit.fromContext(BuildContext context) {
    return PantryFilterCubit(
      pantryBloc: context.read<PantryBloc>(),
    );
  }

  void show(SensitivityLevel level) => _updateFilter(_filter.show(level));
  void hide(SensitivityLevel level) => _updateFilter(_filter.hide(level));
  void toggle(SensitivityLevel level) => _updateFilter(_filter.toggle(level));
  void showAll() => _updateFilter(PantryFilter.all());

  void _updateFilter(PantryFilter filter) {
    if (pantryBloc.state is PantryLoaded) {
      final items = (pantryBloc.state as PantryLoaded).items;
      final filteredItems = BuiltList<PantryEntry>(items.where(filter.isIncluded));
      emit(PantryFilterLoaded(items: filteredItems, filter: filter));
    } else if (pantryBloc.state is PantryLoading) {
      emit(PantryFilterLoading(filter: filter));
    }
  }
}

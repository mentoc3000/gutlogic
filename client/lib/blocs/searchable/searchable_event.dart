import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/model_interfaces.dart';

mixin FetchQuery on Equatable {
  String get query;

  @override
  List<Object?> get props => [query];
}

mixin StreamAll on Equatable {}

mixin StreamQuery on Equatable {
  String get query;

  @override
  List<Object?> get props => [query];
}

mixin LoadSearchables on Equatable {
  BuiltList<Searchable> get items;

  @override
  List<Object?> get props => [items];
}

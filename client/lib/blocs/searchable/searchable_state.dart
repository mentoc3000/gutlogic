import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/model_interfaces.dart';

mixin SearchableLoading on Equatable {
  @override
  List<Object> get props => [];

  @override
  String toString() => '$runtimeType';
}

mixin SearchableLoaded on Equatable {
  BuiltList<Searchable> get items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => '$runtimeType { Searchable: ${items?.length} }';
}

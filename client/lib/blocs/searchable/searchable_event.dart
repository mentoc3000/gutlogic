import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import '../../models/model_interfaces.dart';

// TODO: remove this mixin?
mixin FetchAll on Equatable {}

mixin FetchQuery on Equatable {
  String get query;

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'FetchQuery { query: $query }';
}

mixin StreamAll on Equatable {}

mixin StreamQuery on Equatable {
  String get query;

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'StreamQuery { query: $query }';
}

mixin LoadSearchables on Equatable {
  BuiltList<Searchable> get items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'LoadSearchables { item count: ${items.length} }';
}

mixin ThrowSearchableError on Equatable {
  Object get error;
  StackTrace get trace;

  @override
  List<Object> get props => [error, trace];

  @override
  String toString() => 'ThrowSearchableError { error: $error }';
}

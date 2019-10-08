import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

abstract class SearchableState extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchableLoading extends SearchableState {
  @override
  String toString() => 'SearchableLoading';
}

class SearchableLoaded<T extends Searchable> extends SearchableState {
  final BuiltList<T> items;

  SearchableLoaded([this.items]);

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchableLoaded { Searchable: ${items.length} }';
}

class SearchableError extends SearchableState {
  @override
  String toString() => 'SearchableError';
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

@immutable
abstract class SearchableState extends Equatable {
  SearchableState([List props = const []]) : super(props);
}

class SearchableLoading extends SearchableState {
  @override
  String toString() => 'SearchableLoading';
}

class SearchableLoaded<T extends Searchable> extends SearchableState {
  final BuiltList<T> items;

  SearchableLoaded([this.items]) : super([items]);

  @override
  String toString() => 'SearchableLoaded { Searchable: ${items.length} }';
}

class SearchableError extends SearchableState {
  @override
  String toString() => 'SearchableError';
}
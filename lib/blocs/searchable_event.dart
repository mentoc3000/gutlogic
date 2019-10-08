import 'package:equatable/equatable.dart';

abstract class SearchableEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchAll extends SearchableEvent {
  @override
  String toString() => 'FetchAll';
}

class FetchQuery extends SearchableEvent {
  final String query;

  FetchQuery(this.query);

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'FetchQuery { query: $query }';
}

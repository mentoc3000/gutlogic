import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchableEvent extends Equatable {
  SearchableEvent([List props = const []]) : super(props);
}

class FetchAll extends SearchableEvent {
  @override
  String toString() => 'FetchAll';
}

class FetchQuery extends SearchableEvent {
  final String query;

  FetchQuery(this.query) : super([query]);

  @override
  String toString() => 'FetchQuery { query: $query }';
}

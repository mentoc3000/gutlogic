import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/model_interfaces.dart';

@immutable
abstract class DatabaseEvent extends Equatable {
  DatabaseEvent([List props = const []]) : super(props);
}

class FetchAll extends DatabaseEvent {
  @override
  String toString() => 'FetchAll';
}

class FetchQuery extends DatabaseEvent {
  final String query;

  FetchQuery(this.query) : super([query]);

  @override
  String toString() => 'FetchQuery { query: $query }';
}


class Insert<T extends DatabaseItem> extends DatabaseEvent {
  final T item;

  Insert(this.item) : super([item]);

  @override
  String toString() => 'Insert { item: $item }';
}

class Delete extends DatabaseEvent {
  final String id;

  Delete(this.id) : super([id]);

  @override
  String toString() => 'Delete { id: $id }';
}

class Upsert<T extends DatabaseItem> extends DatabaseEvent {
  final T item;

  Upsert(this.item) : super([item]);

  @override
  String toString() => 'Upsert { item: $item }';
}

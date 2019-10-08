import 'package:equatable/equatable.dart';
import '../models/model_interfaces.dart';

abstract class DatabaseEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchAll extends DatabaseEvent {
  @override
  String toString() => 'FetchAll';
}

class FetchQuery extends DatabaseEvent {
  final String query;

  FetchQuery(this.query);

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'FetchQuery { query: $query }';
}

class Insert<T extends DatabaseItem> extends DatabaseEvent {
  final T item;

  Insert(this.item);

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'Insert { item: $item }';
}

class Delete extends DatabaseEvent {
  final String id;

  Delete(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'Delete { id: $id }';
}

class Update<T extends DatabaseItem> extends DatabaseEvent {
  final T item;

  Update(this.item);

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'Upsert { item: $item }';
}

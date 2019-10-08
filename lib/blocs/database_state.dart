import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

abstract class DatabaseState extends Equatable {
  @override
  List<Object> get props => [];
}

class DatabaseLoading extends DatabaseState {
  @override
  String toString() => 'DatabaseLoading';
}

class DatabaseLoaded<T extends DatabaseItem> extends DatabaseState {
  final BuiltList<T> items;

  DatabaseLoaded([this.items]);

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'DatabaseLoaded { Database: ${items.length} }';
}

class DatabaseError extends DatabaseState {
  @override
  String toString() => 'DatabaseError';
}

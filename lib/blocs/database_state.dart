import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';

@immutable
abstract class DatabaseState extends Equatable {
  DatabaseState([List props = const []]) : super(props);
}

class DatabaseLoading extends DatabaseState {
  @override
  String toString() => 'DatabaseLoading';
}

class DatabaseLoaded extends DatabaseState {
  final BuiltList<DatabaseItem> items;

  DatabaseLoaded([this.items]) : super([items]);

  @override
  String toString() => 'DatabaseLoaded { Database: ${items.length} }';
}

class DatabaseError extends DatabaseState {
  @override
  String toString() => 'DatabaseError';
}
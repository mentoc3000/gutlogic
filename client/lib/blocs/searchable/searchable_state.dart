import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/model_interfaces.dart';
import '../bloc_helpers.dart';

mixin SearchableLoading on Equatable {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'SearchableLoading';
}

mixin SearchableLoaded on Equatable {
  BuiltList<Searchable> get items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchableLoaded { Searchable: ${items?.length} }';
}

mixin SearchableError on Equatable implements ErrorRecorder {
  String get message;

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'SearchableError { message: $message }';
}

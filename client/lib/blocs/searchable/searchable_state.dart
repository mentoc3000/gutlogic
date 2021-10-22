import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/model_interfaces.dart';

mixin SearchableLoading on Equatable {
  @override
  List<Object?> get props => [];
}

mixin SearchableLoaded on Equatable {
  BuiltList<Searchable> get items;

  @override
  List<Object?> get props => [items];
}

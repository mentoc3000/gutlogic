import 'package:meta/meta.dart';
import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';

abstract class SearchableBloc<T extends Searchable,
    R extends SearchableRepository> {
  @protected
  final R repository;

  @protected
  final controller = StreamController<BuiltList<T>>.broadcast();

  Stream<BuiltList<T>> get all => controller.stream;

  SearchableBloc(this.repository);

  void fetchAll() async {
    BuiltList<T> items = await repository.fetchAll();
    controller.sink.add(items);
  }

  void fetchQuery(String query) async {
    BuiltList<T> items = await repository.fetchQuery(query);
    controller.sink.add(items);
  }

  dispose() {
    controller.close();
  }
}

import 'package:meta/meta.dart';
import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';
import 'searchable_bloc.dart';

abstract class DatabaseBloc<T extends DatabaseItem,
    R extends DatabaseRepository> extends SearchableBloc<T, R> {
  DatabaseBloc(R repository) : super(repository);

  void insert(T item) async => repository.insert(item);
  void insertAll(Iterable<T> items) async => repository.insertAll(items);
  void delete(String id) async => repository.delete(id);
  void upsert(T item) async => repository.upsert(item);
}

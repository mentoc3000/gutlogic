import 'dart:async';
import 'package:built_collection/built_collection.dart';
import '../models/model_interfaces.dart';
import '../resources/repository_interfaces.dart';

abstract class GutAiBloc {

  final SearchableRepository repository;

  GutAiBloc({this.repository});

}

abstract class SearchableBloc extends GutAiBloc {

  final controller = StreamController<BuiltList<Searchable>>.broadcast();

  Stream<BuiltList<Searchable>> get all => controller.stream;

  SearchableBloc({SearchableRepository repository})
    : super(repository: repository);

  void fetchAll() async {
    BuiltList<Searchable> items = await repository.fetchAll();
    controller.sink.add(items);
  }

  void fetchQuery(String query) async {
    BuiltList<Searchable> items = await repository.fetchQuery(query);
    controller.sink.add(items);
  }

  dispose() {
    controller.close();
  }

}
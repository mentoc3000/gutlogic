import 'dart:async';
import '../models/model_interfaces.dart';
import '../resources/searchable_repository.dart';

abstract class GutAiBloc {

  final SearchableRepository repository;

  GutAiBloc({this.repository});

}

abstract class SearchableBloc extends GutAiBloc {

  final controller = StreamController<List<Searchable>>.broadcast();

  Stream<List<Searchable>> get all => controller.stream;

  SearchableBloc({SearchableRepository repository})
    : super(repository: repository);

  void fetchAll() async {
    List<Searchable> items = await repository.fetchAll();
    controller.sink.add(items);
  }

  void fetchQuery(String query) async {
    List<Searchable> items = await repository.fetchQuery(query);
    controller.sink.add(items);
  }

  dispose() {
    controller.close();
  }

}
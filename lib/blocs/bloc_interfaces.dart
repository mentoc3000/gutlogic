import 'dart:async';
import '../models/model_interfaces.dart';
import '../resources/searchable_repository.dart';

abstract class GutAiBloc {

  final SearchableRepository repository;

  final controller = StreamController<List<Searchable>>.broadcast();

  GutAiBloc({this.repository});

  dispose() {
    controller.close();
  }

}

abstract class SearchableBloc extends GutAiBloc {
  Stream<List<Searchable>> get all => controller.stream;

  SearchableBloc({SearchableRepository repository})
    : super(repository: repository);

  void fetchAll() async {
    List<Searchable> foods = await repository.fetchAll();
    controller.sink.add(foods);
  }

  void fetchQuery(String query) async {
    List<Searchable> foods = await repository.fetchQuery(query);
    controller.sink.add(foods);
  }

}
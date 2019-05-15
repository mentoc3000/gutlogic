abstract class GutAiBloc {
  
}

abstract class SearchableBloc extends GutAiBloc {
  void fetchAll();
  void fetchQuery(String query);
}
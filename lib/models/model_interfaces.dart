abstract class Searchable {
  String searchHeading();
  String queryText();
}

abstract class DatabaseItem extends Searchable {
  String get id;
}
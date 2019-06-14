abstract class Searchable {
  String searchHeading();
}

abstract class DatabaseItem extends Searchable {
  String get id;
}
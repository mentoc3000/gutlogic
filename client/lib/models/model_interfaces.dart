abstract class Searchable {
  String searchHeading();
  String queryText();
}

mixin Ided {
  String get id;
}

mixin UserFoodDetail {
  String get userFoodDetailsId;
}

mixin Named {
  String get name;
}

mixin Versioned {
  int get version;
}

mixin Dated {
  DateTime get datetime;
}

mixin Noted {
  String? get notes;
}

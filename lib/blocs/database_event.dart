import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DatabaseEvent extends Equatable {
  DatabaseEvent([List props = const []]) : super(props);
}

class Insert extends DatabaseEvent {
  final String item;

  Insert(this.item) : super([item]);

  @override
  String toString() => 'FetchQuery { item: $item }';
}

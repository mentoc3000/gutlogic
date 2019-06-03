import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TabEvent extends Equatable {
  TabEvent([List props = const []]) : super(props);
}

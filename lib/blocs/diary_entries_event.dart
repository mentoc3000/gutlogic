import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DiaryEntriesEvent extends Equatable {
  DiaryEntriesEvent([List props = const []]) : super(props);
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ConsentSubmitted extends ConsentEvent {
  const ConsentSubmitted();
}

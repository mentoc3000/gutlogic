import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String email;

  const ResetPasswordSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

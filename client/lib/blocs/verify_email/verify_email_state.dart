import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class VerifyEmailState extends Equatable {
  @override
  List<Object> get props => [];
}

class VerifyEmailLoading extends VerifyEmailState {}

class VerifyEmailExiting extends VerifyEmailState {}

class VerifyEmailValue extends VerifyEmailState {
  final bool verified;

  VerifyEmailValue({@required this.verified});

  @override
  List<Object> get props => [verified];
}

class VerifyEmailError extends VerifyEmailState {
  final String message;

  VerifyEmailError({@required this.message});

  @override
  List<Object> get props => [message];
}

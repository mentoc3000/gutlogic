import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class AuthenticationProvided extends AuthenticationEvent {
  const AuthenticationProvided();

  @override
  String toString() => 'AuthenticationProvided';
}

class AuthenticationRevoked extends AuthenticationEvent {
  const AuthenticationRevoked();

  @override
  String toString() => 'AuthenticationRevoked';
}

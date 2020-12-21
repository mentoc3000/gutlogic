import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationUnknown extends AuthenticationState {
  const AuthenticationUnknown();

  @override
  String toString() => 'AuthenticationUnknown';
}

class Authenticated extends AuthenticationState {
  const Authenticated();

  @override
  String toString() => 'Authenticated';
}

class Unauthenticated extends AuthenticationState {
  const Unauthenticated();

  @override
  String toString() => 'Unauthenticated';
}

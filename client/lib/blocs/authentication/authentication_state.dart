import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationUnknown extends AuthenticationState {
  const AuthenticationUnknown();
}

class Authenticated extends AuthenticationState {
  const Authenticated();
}

class Unauthenticated extends AuthenticationState {
  const Unauthenticated();
}

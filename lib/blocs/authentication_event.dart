import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {
  // Successfully logged in
  @override
  String toString() => 'LoggedIn';
}

class LoggedOut extends AuthenticationEvent {
  // Successfully logged out
  @override
  String toString() => 'LoggedOut';
}

class Reauthenticate extends AuthenticationEvent {
  // Return to login page
  @override
  String toString() => 'Reauthenticate';
}

class Confirm extends AuthenticationEvent {
  final String username;

  Confirm({@required this.username}) : super([username]);

  @override
  String toString() => 'Confirm';
}

class Confirmed extends AuthenticationEvent {
  @override
  String toString() => 'Confirmed';
}

class NewUser extends AuthenticationEvent {
  // Return to login page
  @override
  String toString() => 'NewUser';
}

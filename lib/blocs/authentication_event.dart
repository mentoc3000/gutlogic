import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

// TODO: add constant contructors. See last point here:
// https://github.com/felangel/equatable/blob/master/doc/migration_guides/migration-0.6.0.md

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
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

  Confirm({@required this.username});

  @override
  List<Object> get props => [username];

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

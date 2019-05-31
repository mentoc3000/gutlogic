import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  }) : super([username, password]);

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

class LoginPageButtonPressed extends LoginEvent {
  @override
  String toString() => 'LoginPageButtonPressed';
}

class SignupPageButtonPressed extends LoginEvent {
  @override
  String toString() => 'SignupPageButtonPressed';
}


class SignupButtonPressed extends LoginEvent {
  final String username;
  final String password;

  SignupButtonPressed({
    @required this.username,
    @required this.password,
  }) : super([username, password]);

  @override
  String toString() =>
      'SignupButtonPressed { username: $username, password: $password }';
}

class ConfirmButtonPressed extends LoginEvent {
  final String username;
  final String confirmationCode;

  ConfirmButtonPressed({
    @required this.username,
    @required this.confirmationCode,
  }) : super([username, confirmationCode]);

  @override
  String toString() =>
      'ConfirmButtonPressed { confirmationCode: $confirmationCode }';
}
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

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

class CancelButtonPressed extends LoginEvent {
  @override
  String toString() => 'LoginPageButtonPressed';
}

class SignupButtonPressed extends LoginEvent {
  final String username;
  final String password;

  SignupButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

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
  });

  @override
  List<Object> get props => [username, confirmationCode];

  @override
  String toString() =>
      'ConfirmButtonPressed { confirmationCode: $confirmationCode }';
}

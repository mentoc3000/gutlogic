import 'package:equatable/equatable.dart';

abstract class AccountDeleteEvent extends Equatable {
  const AccountDeleteEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class AccountDeletePasswordConfirm extends AccountDeleteEvent {
  final String password;

  AccountDeletePasswordConfirm({required this.password});

  @override
  List<Object?> get props => [password];
}

class AccountDeleteFederatedConfirm extends AccountDeleteEvent {
  const AccountDeleteFederatedConfirm();
}

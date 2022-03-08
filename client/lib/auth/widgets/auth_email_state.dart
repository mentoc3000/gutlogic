import '../../blocs/bloc_helpers.dart';

abstract class AuthEmailState extends BaseState {
  const AuthEmailState();
}

class AuthEmailInitial extends AuthEmailState {
  const AuthEmailInitial();
}

class AuthEmailAwaitingLink extends AuthEmailState {
  final String email;

  const AuthEmailAwaitingLink({required this.email});

  @override
  List<Object?> get props => [email];
}

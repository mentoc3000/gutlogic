import '../../auth/auth.dart';
import '../bloc_helpers.dart';

abstract class ReauthenticateState extends BaseState {
  const ReauthenticateState();
}

class ReauthenticateInitial extends ReauthenticateState {
  const ReauthenticateInitial();
}

class ReauthenticateLoading extends ReauthenticateState {
  const ReauthenticateLoading();
}

class ReauthenticateSuccess extends ReauthenticateState {
  final AuthMethod method;

  const ReauthenticateSuccess({required this.method});

  @override
  List<Object?> get props => [method];
}

class ReauthenticateFailure extends ReauthenticateState with ErrorState {
  @override
  final String? message;

  const ReauthenticateFailure({this.message});
}

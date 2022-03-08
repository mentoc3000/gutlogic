import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/application_user.dart';
import '../resources/user_repository.dart';

/// Emits a new user object whenever the user model changes.
class UserCubit extends Cubit<ApplicationUser?> {
  UserCubit({required UserRepository repository}) : super(repository.user) {
    repository.stream.listen(emit);
  }
}

/// Rebuilds only for authenticated (non-null) users.
class AuthenticatedUserBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ApplicationUser) builder;

  AuthenticatedUserBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, ApplicationUser?>(
      builder: (context, user) => builder(context, user!),
      buildWhen: (prev, next) => prev != next && next != null,
    );
  }
}

/// Rebuilds when the authentication state changes
class AuthenticationBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool authenticated) builder;

  AuthenticationBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, ApplicationUser?>(
      builder: (context, user) => builder(context, user != null),
      buildWhen: (prev, next) => (prev == null && next != null) || (prev != null && next == null),
    );
  }
}

/// Invokes the [listener] function when the authentication state changes
class AuthenticationListener extends StatelessWidget {
  final Widget Function(BuildContext, bool authenticated) listener;

  AuthenticationListener({required this.listener});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, ApplicationUser?>(
      listener: (context, user) => listener(context, user != null),
      listenWhen: (prev, next) => (prev == null && next != null) || (prev != null && next == null),
    );
  }
}

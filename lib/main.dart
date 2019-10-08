import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'resources/user_repository.dart';

import 'blocs/authentication_bloc.dart';
import 'blocs/authentication_state.dart';
import 'blocs/authentication_event.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/main_tabs.dart';
import 'package:gut_ai/pages/main_tabs.dart';
import 'pages/confirmation_page.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  UserRepository userRepository = UserRepository();
  runApp(App(userRepository: userRepository));
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  UserRepository get _userRepository => widget.userRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      builder: (BuildContext context) {
        AuthenticationBloc _authenticationBloc =
            AuthenticationBloc(userRepository: _userRepository);
        _authenticationBloc.dispatch(AppStarted());
        return _authenticationBloc;
      },
      child: MaterialApp(
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }
            if (state is AuthenticationAuthenticated) {
              return Tabbed(userRepository: _userRepository);
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: _userRepository);
            }
            if (state is AuthenticationNewUser) {
              return SignupPage(userRepository: _userRepository);
            }
            if (state is AuthenticationUnconfirmed) {
              return ConfirmationPage(
                username: state.username,
                userRepository: _userRepository,
              );
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
          },
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}

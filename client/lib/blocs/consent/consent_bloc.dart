import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/user_repository.dart';
import 'consent_event.dart';
import 'consent_state.dart';

class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  final UserRepository userRepository;

  factory ConsentBloc.fromContext(BuildContext context) {
    return ConsentBloc(userRepository: context.read<UserRepository>());
  }

  ConsentBloc({@required this.userRepository}) : super(const ConsentReady());

  @override
  Stream<ConsentState> mapEventToState(ConsentEvent event) async* {
    if (event is ConsentSubmitted) {
      yield* _mapConsentSubmittedToState(event);
    }
  }

  Stream<ConsentState> _mapConsentSubmittedToState(ConsentSubmitted event) async* {
    try {
      yield const ConsentLoading();
      await userRepository.updateMetadata(updatedUser: userRepository.user.rebuild((b) => b..consented = true));
      yield const ConsentDone();
    } catch (error, trace) {
      yield ConsentError.fromError(error: error, trace: trace);
      yield const ConsentReady();
    }
  }
}

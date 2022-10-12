import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user/application_user.dart';
import '../../resources/user_repository.dart';
import '../bloc_helpers.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> with StreamSubscriber<ApplicationUser?, SubscriptionState> {
  final UserRepository userRepository;

  SubscriptionCubit({
    required this.userRepository,
  }) : super(const SubscriptionLoading()) {
    streamSubscription = userRepository.stream.listen(_onData, onError: _onError);
  }

  factory SubscriptionCubit.fromContext(BuildContext context) {
    return SubscriptionCubit(
      userRepository: context.read<UserRepository>(),
    );
  }

  void _onData(ApplicationUser? user) async {
    if (user != null && user.hasActivePremiumSubscription) {
      emit(const Subscribed());
    }
  }

  void _onError(Object error, StackTrace trace) {
    final startingState = state;
    emit(SubscriptionError.fromError(error: error, trace: trace));
    emit(startingState);
  }
}

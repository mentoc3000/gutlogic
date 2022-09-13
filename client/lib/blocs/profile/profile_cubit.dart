import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(ProfileInitial(repository.value));

  static BlocProvider<ProfileCubit> provider({required Widget child}) {
    return BlocProvider(create: (c) => ProfileCubit(repository: c.read<ProfileRepository>()), child: child);
  }

  Future<void> update(Profile profile) async {
    assert(state is! ProfileSaving);

    try {
      emit(ProfileSaving(profile));
      await repository.update(profile: profile);
      emit(ProfileSuccess(profile));
    } catch (ex) {
      emit(ProfileFailure(repository.value));
    }
  }
}

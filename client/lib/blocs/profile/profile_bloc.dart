import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/profile_repository.dart';
import '../bloc_helpers.dart';

export '../bloc_helpers.dart';

class ProfileBloc extends Cubit<UpdateState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const UpdateInitialState());

  Future<void> update({required Profile profile}) async {
    if (state is UpdateSavingState) return;

    try {
      emit(const UpdateSavingState());
      await _repository.update(profile: profile);
      emit(const UpdateSuccessState());
    } catch (ex) {
      emit(const UpdateFailureState());
    }
  }
}

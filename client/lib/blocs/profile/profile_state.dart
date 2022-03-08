import '../../models/profile.dart';
import '../bloc_helpers.dart';

class ProfileState extends BaseState {
  final Profile profile;

  ProfileState(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileInitial extends ProfileState {
  ProfileInitial(Profile profile) : super(profile);
}

class ProfileSaving extends ProfileState {
  ProfileSaving(Profile profile) : super(profile);
}

class ProfileSuccess extends ProfileState {
  ProfileSuccess(Profile profile) : super(profile);
}

class ProfileFailure extends ProfileState with ErrorState {
  @override
  final String? message;

  ProfileFailure(Profile profile, {this.message}) : super(profile);

  @override
  List<Object?> get props => [message];
}

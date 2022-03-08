import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/profile/profile.dart';
import '../../resources/profile_repository.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/error_snack_bar.dart';
import '../../widgets/utility/subject_value_builder.dart';
import 'widgets/profile_form.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Profile'),
      body: LoadingBuilder.stream(
        stream: context.read<ProfileRepository>().stream,
        builder: (BuildContext context, Profile profile) {
          return SingleChildScrollView(child: ProfilePageBody(profile: profile));
        },
      ),
    );
  }
}

class ProfilePageBody extends StatelessWidget {
  final Profile profile;

  ProfilePageBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    void navigate(context, state) {
      if (state is ProfileSuccess) Navigator.of(context).pop();
      if (state is ProfileFailure) ErrorSnackBar.show(context, state);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ProfileCubit.provider(
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: navigate,
          child: ProfileForm(profile: profile),
        ),
      ),
    );
  }
}

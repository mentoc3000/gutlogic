import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../blocs/profile/profile.dart';
import '../../../resources/profile_repository.dart';
import '../../../widgets/buttons/buttons.dart';

class ProfileForm extends StatefulWidget {
  final Profile profile;

  ProfileForm({required this.profile});

  @override
  ProfileFormState createState() => ProfileFormState(profile: profile);
}

class ProfileFormState extends State<ProfileForm> {
  final TextEditingController _firstnameController;
  final TextEditingController _lastnameController;

  ProfileFormState({required Profile profile})
      : _firstnameController = TextEditingController(text: profile.firstname),
        _lastnameController = TextEditingController(text: profile.lastname);

  @override
  Widget build(BuildContext context) {
    void submit() {
      final firstname = _firstnameController.text;
      final lastname = _lastnameController.text;
      context.read<ProfileCubit>().update(Profile(firstname: firstname, lastname: lastname));
    }

    return Column(
      children: [
        ProfileFormFirstName(
          controller: _firstnameController,
        ),
        const Gap(20),
        ProfileFormLastName(
          controller: _lastnameController,
        ),
        const Gap(20),
        ProfileFormSaveButton(onPressed: submit)
      ],
    );
  }
}

class ProfileFormFirstName extends StatelessWidget {
  final TextEditingController controller;

  ProfileFormFirstName({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'First Name'),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class ProfileFormLastName extends StatelessWidget {
  final TextEditingController controller;

  ProfileFormLastName({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Last Name'),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class ProfileFormSaveButton extends StatelessWidget {
  final void Function() onPressed;

  ProfileFormSaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Save'),
      enabled: context.select((ProfileCubit cubit) => cubit.state is! ProfileSaving),
      onPressed: onPressed,
    );
  }
}

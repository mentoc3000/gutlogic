import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../blocs/bloc_helpers.dart';
import '../../../blocs/profile/profile_bloc.dart';
import '../../../input/input.dart';
import '../../../resources/profile_repository.dart';
import '../../../widgets/buttons/buttons.dart';

class ProfileForm extends StatelessWidget {
  final Profile? profile;

  ProfileForm({required this.profile});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (c) => ProfileBloc(repository: c.read<ProfileRepository>())),
        BlocProvider(create: (c) => ProfileFormInputs(profile: profile)),
      ],
      child: BlocListener<ProfileBloc, UpdateState>(
        listener: (context, state) {
          if (state is UpdateSuccessState) Navigator.of(context).pop();
        },
        child: ListView(
          children: [
            ProfileFormFirstName(),
            const SizedBox(height: 20),
            ProfileFormLastName(),
            const SizedBox(height: 20),
            ProfileFormSaveButton(),
          ],
        ),
      ),
    );
  }
}

class ProfileFormInputs extends InputGroup {
  final InputText firstname;
  final InputText lastname;

  ProfileFormInputs({Profile? profile})
      : firstname = InputText(value: profile?.firstname ?? ''),
        lastname = InputText(value: profile?.lastname ?? '');

  @override
  List<Input> get inputs => [firstname, lastname];
}

class ProfileFormFirstName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'First Name'),
      controller: context.select((ProfileFormInputs i) => i.firstname.controller),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class ProfileFormLastName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'Last Name'),
      controller: context.select((ProfileFormInputs i) => i.lastname.controller),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class ProfileFormSaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Save'),
      enabled: context.select((ProfileBloc c) => c.state is! UpdateSavingState),
      onPressed: () => _submit(context),
    );
  }

  void _submit(BuildContext context) {
    final input = context.read<ProfileFormInputs>();
    final cubit = context.read<ProfileBloc>();

    cubit.update(
      profile: Profile(
        firstname: input.firstname.value,
        lastname: input.lastname.value,
      ),
    );
  }
}

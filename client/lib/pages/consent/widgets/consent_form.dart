import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/consent/consent.dart';
import '../../../widgets/buttons/buttons.dart';

class ConsentForm extends StatefulWidget {
  @override
  ConsentFormState createState() => ConsentFormState();
}

class ConsentFormState extends State<ConsentForm> {
  bool _isMinimumAge = false;
  bool _isPrivacyPolicyReviewed = false;

  @override
  Widget build(BuildContext context) {
    final state = context.select((ConsentCubit cubit) => cubit.state);

    final editable = (state is ConsentInitial);
    final submittable = editable && _isMinimumAge && _isPrivacyPolicyReviewed;

    return Column(children: [
      ConsentFormMinimumAgeCheckbox(
        value: _isMinimumAge,
        onChanged: editable ? (v) => setState(() => _isMinimumAge = v) : null,
      ),
      ConsentFormPrivacyCheckbox(
        value: _isPrivacyPolicyReviewed,
        onChanged: editable ? (v) => setState(() => _isPrivacyPolicyReviewed = v) : null,
      ),
      ConsentFormSubmitButton(onPressed: submittable ? () => context.read<ConsentCubit>().consent() : null)
    ]);
  }
}

class ConsentFormMinimumAgeCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  const ConsentFormMinimumAgeCheckbox({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      title: const Text('I am 16 or older.'),
      onChanged: (b) => onChanged?.call(b ?? false),
    );
  }
}

class ConsentFormPrivacyCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  const ConsentFormPrivacyCheckbox({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      title: const Text('I have reviewed the privacy policy.'),
      onChanged: (b) => onChanged?.call(b ?? false),
    );
  }
}

class ConsentFormSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ConsentFormSubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      onPressed: onPressed,
      child: const StretchedButtonContent(label: 'Agree'),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../blocs/consent/consent.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

final _consentImage = SvgPicture.asset('assets/consent/consent_image.svg');

final _consentText = Text.rich(
  TextSpan(
    children: [
      const TextSpan(
        text: 'Our goal at Gut Logic is to improve your health by analyzing what you eat and how it makes you feel. We '
            'are committed to handling your data responsibly and will never sell your personal information.\n\nYou can '
            'delete your data at any time. Please review our ',
      ),
      TextSpan(
        text: 'privacy policy',
        style: const TextStyle(color: GLColors.blue, fontWeight: FontWeight.bold),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            const url = 'http://gutlogic.co/gut_logic_privacy_policy.pdf';
            if (await canLaunch(url)) await launch(url);
          },
      ),
      const TextSpan(
        text: ' and email us at ',
      ),
      const TextSpan(
        text: 'privacy@gutlogic.co',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: ' with any questions.',
      ),
    ],
  ),
);

class ConsentForm extends StatefulWidget {
  @override
  ConsentFormState createState() => ConsentFormState();
}

class ConsentFormState extends State<ConsentForm> {
  bool _isMinimumAge = false;
  bool _isPrivacyReviewed = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConsentBloc, ConsentState>(listener: listener, builder: builder);
  }

  Widget builder(BuildContext context, ConsentState state) {
    final isSubmittable = _isMinimumAge && _isPrivacyReviewed && (state is ConsentReady);

    return ListView(children: [
      SizedBox(height: 200, child: _consentImage),
      Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 40),
        child: _consentText,
      ),
      CheckboxListTile(
        value: _isMinimumAge,
        title: const Text('I am 16 or older.'),
        onChanged: state is ConsentReady ? (value) => onAgeCheckboxChanged(value: value) : null,
      ),
      CheckboxListTile(
        value: _isPrivacyReviewed,
        title: const Text('I have reviewed the privacy policy.'),
        onChanged: state is ConsentReady ? (value) => onPrivacyCheckboxChanged(value: value) : null,
      ),
      GLPrimaryButton(
        child: const StretchedButtonContent(label: 'Agree'),
        onPressed: isSubmittable ? () => onAgreeButtonPressed(context) : null,
      )
    ]);
  }

  void onAgeCheckboxChanged({bool value}) {
    setState(() => {_isMinimumAge = value});
  }

  void onPrivacyCheckboxChanged({bool value}) {
    setState(() => {_isPrivacyReviewed = value});
  }

  void onAgreeButtonPressed(BuildContext context) {
    context.bloc<ConsentBloc>().add(const ConsentSubmitted());
  }

  void listener(BuildContext context, ConsentState state) {
    if (state is ConsentDone) {
      Navigator.of(context).pushAndRemoveUntil(Routes.of(context).main, (_) => false);
    }
    if (state is ConsentError) {
      Scaffold.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    }
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../../style/gl_colors.dart';

class ConsentHeader extends StatelessWidget {
  static final _asset = SvgPicture.asset('assets/consent/consent_image.svg');

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 200, child: _asset),
      const Gap(40),
      Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text:
                  'Our goal at Gut Logic is to improve your health by analyzing what you eat and how it makes you feel. We '
                  'are committed to handling your data responsibly and will never sell your personal information.\n\nYou can '
                  'delete your data at any time. Please review our ',
            ),
            TextSpan(
              text: 'privacy policy',
              style: const TextStyle(color: GLColors.blue, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()..onTap = _navigate,
            ),
            const TextSpan(text: ' and email us at '),
            const TextSpan(text: 'privacy@gutlogic.co', style: TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ' with any questions.'),
          ],
        ),
      ),
    ]);
  }

  static void _navigate() async {
    const url = 'http://gutlogic.co/gut_logic_privacy_policy.pdf';
    if (await url_launcher.canLaunch(url)) await url_launcher.launch(url);
  }
}

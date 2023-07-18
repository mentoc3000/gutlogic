import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../style/gl_text_style.dart';

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
            hyperlink(text: 'privacy policy', url: 'https://gutlogic.co/privacy'),
            const TextSpan(text: ' and email us at '),
            hyperlink(text: 'privacy@gutlogic.co', url: 'mailto:privacy@gutlogic.co'),
            const TextSpan(text: ' with any questions.'),
          ],
        ),
      ),
    ]);
  }
}

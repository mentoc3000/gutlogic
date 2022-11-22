import 'package:flutter/widgets.dart';

import '../../../resources/legal_service.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';

class LegalLinks extends StatelessWidget {
  const LegalLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: GLColors.white, fontSize: 14.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        GLTertiaryButton(
          onPressed: LegalService.openPrivacyPolicy,
          child: ShrinkWrappedButtonContent(label: 'Privacy Policy', textStyle: style),
        ),
        GLTertiaryButton(
          onPressed: LegalService.openTermsOfUse,
          child: ShrinkWrappedButtonContent(label: 'Terms of Use', textStyle: style),
        ),
      ],
    );
  }
}

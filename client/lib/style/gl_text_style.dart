import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'gl_colors.dart';

const TextStyle logoFont = TextStyle(
  fontFamily: 'Quicksand480',
  letterSpacing: 3,
  color: GLColors.green,
);

const TextStyle appleFont = TextStyle(fontFamily: 'SanFrancisco');

final TextStyle googleFont = GoogleFonts.roboto(fontWeight: FontWeight.w500);

void addFontLicenseToRegistry(AssetBundle rootBundle) {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

const tileHeadingStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
const tileSubheadingStyle = TextStyle(fontSize: 16.0);
final TextStyle guideTextStyle = TextStyle(fontSize: 16.0, color: GLColors.darkGray);

TextSpan hyperlink({required String text, required String url}) {
  void navigate() async {
    final dest = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(dest)) await url_launcher.launchUrl(dest);
  }

  return TextSpan(
    text: text,
    style: const TextStyle(color: GLColors.blue, fontWeight: FontWeight.bold),
    recognizer: TapGestureRecognizer()..onTap = navigate,
  );
}

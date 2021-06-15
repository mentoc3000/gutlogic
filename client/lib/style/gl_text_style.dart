import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

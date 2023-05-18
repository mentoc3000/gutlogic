import 'package:url_launcher/url_launcher.dart' as url;

class LegalService {
  LegalService._();

  static void openPrivacyPolicy() async {
    final dest = Uri.parse('https://gutlogic.co/privacy');
    if (await url.canLaunchUrl(dest)) await url.launchUrl(dest);
  }

  static void openTermsOfUse() async {
    final dest = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
    if (await url.canLaunchUrl(dest)) await url.launchUrl(dest);
  }
}

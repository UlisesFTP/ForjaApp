import 'package:url_launcher/url_launcher.dart';

abstract class TutorialLauncher {
  Future<bool> open(Uri uri);
}

class ExternalTutorialLauncher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

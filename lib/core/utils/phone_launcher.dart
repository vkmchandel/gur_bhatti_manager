import 'package:url_launcher/url_launcher.dart';

Future<void> launchDialer(String mobile) async {
  final uri = Uri(scheme: 'tel', path: mobile);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

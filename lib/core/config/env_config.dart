import 'package:flutter_dotenv/flutter_dotenv.dart';

final class EnvConfig {
  EnvConfig._();

  static String _get(String key, [String fallback = '']) {
    return dotenv.env[key]?.trim() ?? fallback;
  }

  static String get baseUrl =>
      _get('BASE_URL', 'https://backiam.dentin.cloud');

  static String get tapSecretKey => _get('TAP_SECRET_KEY');

  static String get tapApiUrl =>
      _get('TAP_API_URL', 'https://api.tap.company');

  static String get tapRedirectUrl =>
      _get('TAP_REDIRECT_URL', 'https://yourdomain.com/tap/callback');
}

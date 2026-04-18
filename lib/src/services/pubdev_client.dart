import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/package_info.dart';

class PubDevClient {
  final http.Client _client;

  PubDevClient({http.Client? client}) : _client = client ?? http.Client();

  Future<PackageInfo> fetchPackageInfo(String packageName) async {
    try {
      final response = await _client.get(
        Uri.parse('https://pub.dev/api/packages/$packageName'),
      );

      if (response.statusCode != 200) {
        return PackageInfo(name: packageName);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final latest = data['latest'] as Map<String, dynamic>?;

      if (latest == null) {
        return PackageInfo(name: packageName);
      }

      final pubspec = latest['pubspec'] as Map<String, dynamic>?;
      String? repositoryUrl;
      List<String> platforms = [];

      if (pubspec != null) {
        repositoryUrl = pubspec['repository']?.toString();

        final flutter = pubspec['flutter'] as Map<String, dynamic>?;
        if (flutter != null) {
          final plugin = flutter['plugin'] as Map<String, dynamic>?;
          if (plugin != null) {
            platforms.addAll((plugin['platforms'] as List?)?.map((e) => e.toString()) ?? []);
          }
        }
      }

      DateTime? latestPublished;
      if (latest['published'] != null) {
        latestPublished = DateTime.tryParse(latest['published'].toString());
      }

      return PackageInfo(
        name: packageName,
        version: latest['version']?.toString(),
        repositoryUrl: repositoryUrl,
        latestPublished: latestPublished,
        isNullSafe: _checkNullSafety(pubspec),
        platforms: platforms,
      );
    } catch (e) {
      return PackageInfo(name: packageName);
    }
  }

  bool _checkNullSafety(Map<String, dynamic>? pubspec) {
    if (pubspec == null) return false;
    final environment = pubspec['environment'] as Map<String, dynamic>?;
    if (environment == null) return false;
    final sdk = environment['sdk'];
    if (sdk == null) return false;
    return sdk.toString().contains('>=') || sdk.toString().startsWith('^');
  }
}
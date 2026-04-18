import 'dart:io';
import 'package:yaml/yaml.dart';

class PubspecDependency {
  final String name;
  final String? version;
  final bool isDev;
  final bool isOverride;

  const PubspecDependency({
    required this.name,
    this.version,
    this.isDev = false,
    this.isOverride = false,
  });
}

class PubspecParser {
  Future<Map<String, PubspecDependency>> parse(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('pubspec.yaml not found at $filePath');
    }

    final content = await file.readAsString();
    final yaml = loadYaml(content);

    if (yaml == null) {
      throw Exception('Invalid pubspec.yaml');
    }

    final dependencies = <String, PubspecDependency>{};

    _parseDependencySection(yaml['dependencies'], dependencies, false);
    _parseDependencySection(yaml['dev_dependencies'], dependencies, true);
    _parseDependencySection(yaml['dependency_overrides'], dependencies, false, true);

    return dependencies;
  }

  void _parseDependencySection(
    dynamic section,
    Map<String, PubspecDependency> dependencies,
    bool isDev, [
    bool isOverride = false,
  ]) {
    if (section == null) return;

    final Map<dynamic, dynamic> deps = section as Map;
    for (final entry in deps.entries) {
      final name = entry.key.toString();
      if (name == 'flutter') continue;

      String? version;
      if (entry.value is String) {
        version = entry.value.toString();
      } else if (entry.value is Map) {
        final map = entry.value as Map;
        version = map['version']?.toString();
      }

      dependencies[name] = PubspecDependency(
        name: name,
        version: version,
        isDev: isDev,
        isOverride: isOverride,
      );
    }
  }
}
import 'dart:io';
import 'package:args/args.dart';
import '../models/package_info.dart';
import '../services/pubspec_parser.dart';
import '../services/pubdev_client.dart';
import '../services/github_client.dart';
import '../services/scoring_engine.dart';
import '../formatters/output_formatter.dart';

/// Command to check dependencies in a pubspec.yaml file.
class CheckCommand {
  final PubDevClient _pubDevClient;
  final GitHubClient _gitHubClient;
  final ScoringEngine _scoringEngine;
  final OutputFormatter _formatter;

  /// Creates a new CheckCommand with optional dependencies.
  CheckCommand({
    PubDevClient? pubDevClient,
    GitHubClient? gitHubClient,
    ScoringEngine? scoringEngine,
    OutputFormatter? formatter,
  })  : _pubDevClient = pubDevClient ?? PubDevClient(),
        _gitHubClient = gitHubClient ?? GitHubClient(),
        _scoringEngine = scoringEngine ?? ScoringEngine(),
        _formatter = formatter ?? OutputFormatter();

  /// Runs the check command with the given arguments.
  Future<void> run(ArgResults args) async {
    final path = args.rest.isEmpty ? 'pubspec.yaml' : args.rest.first;
    final format = args['format'] as String? ?? 'table';

    print('Analyzing dependencies in $path...\n');

    final parser = PubspecParser();
    final dependencies = await parser.parse(path);

    print('Found ${dependencies.length} dependencies\n');

    final scores = <HealthScore>[];
    final depList = dependencies.values.toList();

    for (var i = 0; i < depList.length; i++) {
      final dep = depList[i];
      stdout.write('\rProcessing: ${dep.name} (${i + 1}/${depList.length})');
      stdout.flush();

      var pkgInfo = await _pubDevClient.fetchPackageInfo(dep.name);
      pkgInfo = await _gitHubClient.enrichWithGitHubData(pkgInfo, null);

      final score = _scoringEngine.calculate(pkgInfo);
      scores.add(score);
    }

    print('\n\n${_formatter.format(scores, format: format)}');

    final highRisk = scores.where((s) => s.riskLevel == RiskLevel.high).toList();
    if (highRisk.isNotEmpty && args['fail-on-risk'] == true) {
      print('\n${highRisk.length} high-risk dependencies found!');
      print('Use --override to ignore failures');
      return;
    }
  }
}
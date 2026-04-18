/// PubGuard - Plugin Health Monitor for Flutter
///
/// A tool that analyzes Flutter/Dart dependencies and provides health scores,
/// risk warnings, and actionable recommendations.
///
/// ## Usage
///
/// ```dart
/// import 'package:pubguard/pubguard.dart';
///
/// void main() async {
///   final scoringEngine = ScoringEngine();
///   final pubDevClient = PubDevClient();
///
///   // Fetch package info
///   final pkgInfo = await pubDevClient.fetchPackageInfo('http');
///
///   // Calculate health score
///   final score = scoringEngine.calculate(pkgInfo);
///
///   print('Package: ${score.packageName}');
///   print('Score: ${score.score}');
///   print('Risk: ${score.riskLevel}');
/// }
/// ```
library pubguard;

export 'src/models/package_info.dart';
export 'src/services/pubspec_parser.dart';
export 'src/services/pubdev_client.dart';
export 'src/services/github_client.dart';
export 'src/services/scoring_engine.dart';
export 'src/formatters/output_formatter.dart';
export 'src/commands/commands.dart';
export 'src/commands/check_command.dart';
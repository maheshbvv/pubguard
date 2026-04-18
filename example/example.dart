import 'package:pubguard/pubguard.dart';

void main() async {
  final scoringEngine = ScoringEngine();
  final pubDevClient = PubDevClient();
  final formatter = OutputFormatter();

  final packageNames = ['http', 'yaml', 'path', 'async'];

  print('Checking package health scores...\n');

  final scores = <HealthScore>[];

  for (final name in packageNames) {
    final pkgInfo = await pubDevClient.fetchPackageInfo(name);
    final score = scoringEngine.calculate(pkgInfo);
    scores.add(score);
  }

  print(formatter.format(scores, format: 'table'));
}
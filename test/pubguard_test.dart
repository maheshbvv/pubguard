import 'package:pubguard/pubguard.dart';
import 'package:test/test.dart';

void main() {
  group('ScoringEngine', () {
    test('calculates health score correctly', () {
      final engine = ScoringEngine();
      final pkg = PackageInfo(
        name: 'test_package',
        latestPublished: DateTime.now().subtract(const Duration(days: 30)),
        lastCommitDate: DateTime.now().subtract(const Duration(days: 15)),
        openIssuesCount: 5,
        closedIssuesCount: 20,
        isNullSafe: true,
        platforms: ['android', 'ios'],
      );

      final score = engine.calculate(pkg);

      expect(score.packageName, 'test_package');
      expect(score.score, greaterThan(0));
      expect(score.score, lessThanOrEqualTo(100));
    });

    test('assigns correct risk level', () {
      final engine = ScoringEngine();

      var highPkg = PackageInfo(name: 'high', latestPublished: DateTime(2020));
      expect(engine.calculate(highPkg).riskLevel, RiskLevel.high);

      var medPkg = PackageInfo(
        name: 'med',
        latestPublished: DateTime.now().subtract(const Duration(days: 120)),
        isNullSafe: true,
      );
      expect(engine.calculate(medPkg).riskLevel, RiskLevel.medium);

      var lowPkg = PackageInfo(
        name: 'low',
        latestPublished: DateTime.now(),
        lastCommitDate: DateTime.now(),
        isNullSafe: true,
      );
      expect(engine.calculate(lowPkg).riskLevel, RiskLevel.low);
    });
  });

  group('PubspecParser', () {
    test('can be instantiated', () {
      final parser = PubspecParser();
      expect(parser, isNotNull);
    });
  });
}
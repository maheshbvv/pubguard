import '../models/package_info.dart';

class ScoringEngine {
  static const Map<String, double> weights = {
    'lastUpdateRecency': 25.0,
    'openIssues': 20.0,
    'issueResolution': 10.0,
    'platformSupport': 15.0,
    'nullSafety': 10.0,
    'githubActivity': 20.0,
  };

  HealthScore calculate(PackageInfo pkg) {
    final metrics = <String, double>{};
    final warnings = <String>[];
    final recommendations = <String>[];

    metrics['lastUpdateRecency'] = _scoreLastUpdate(pkg.latestPublished, warnings);
    metrics['openIssues'] = _scoreOpenIssues(pkg.openIssuesCount, warnings);
    metrics['issueResolution'] = _scoreIssueResolution(
      pkg.openIssuesCount,
      pkg.closedIssuesCount,
    );
    metrics['platformSupport'] = _scorePlatformSupport(pkg.platforms, warnings);
    metrics['nullSafety'] = _scoreNullSafety(pkg.isNullSafe, warnings);
    metrics['githubActivity'] = _scoreGitHubActivity(pkg.lastCommitDate, warnings, recommendations);

    double totalScore = 0;
    for (final entry in metrics.entries) {
      totalScore += (entry.value * weights[entry.key]!) / 100;
    }

    final score = totalScore.round().clamp(0, 100);
    final riskLevel = HealthScore.calculateRiskLevel(score);

    _generateRecommendations(warnings, recommendations, pkg);

    return HealthScore(
      packageName: pkg.name,
      score: score,
      riskLevel: riskLevel,
      metricScores: metrics,
      warnings: warnings,
      recommendations: recommendations,
    );
  }

  double _scoreLastUpdate(DateTime? lastPublished, List<String> warnings) {
    if (lastPublished == null) {
      warnings.add('No published date available');
      return 50.0;
    }

    final daysSinceUpdate = DateTime.now().difference(lastPublished).inDays;
    if (daysSinceUpdate > 365) {
      warnings.add('Package not updated in over a year ($daysSinceUpdate days)');
      return 0.0;
    }
    if (daysSinceUpdate > 180) {
      return 25.0;
    }
    if (daysSinceUpdate > 90) {
      return 50.0;
    }
    if (daysSinceUpdate > 30) {
      return 75.0;
    }
    return 100.0;
  }

  double _scoreOpenIssues(int count, List<String> warnings) {
    if (count > 100) {
      warnings.add('Has $count open issues');
      return 0.0;
    }
    if (count > 50) {
      warnings.add('Has $count open issues');
      return 25.0;
    }
    if (count > 20) {
      return 50.0;
    }
    if (count > 5) {
      return 75.0;
    }
    return 100.0;
  }

  double _scoreIssueResolution(int open, int closed) {
    final total = open + closed;
    if (total == 0) return 50.0;
    final rate = closed / total;
    return (rate * 100).clamp(0, 100);
  }

  double _scorePlatformSupport(List<String> platforms, List<String> warnings) {
    if (platforms.isEmpty) {
      warnings.add('No platform information available');
      return 50.0;
    }
    final score = (platforms.length / 4) * 100;
    return score.clamp(0, 100);
  }

  double _scoreNullSafety(bool isNullSafe, List<String> warnings) {
    if (!isNullSafe) {
      warnings.add('Package is not null safe');
      return 0.0;
    }
    return 100.0;
  }

  double _scoreGitHubActivity(DateTime? lastCommit, List<String> warnings, List<String> recommendations) {
    if (lastCommit == null) {
      warnings.add('No GitHub activity data');
      return 30.0;
    }

    final daysSinceCommit = DateTime.now().difference(lastCommit).inDays;
    if (daysSinceCommit > 365) {
      recommendations.add('Consider alternatives - no commits in over a year');
      return 0.0;
    }
    if (daysSinceCommit > 180) {
      return 25.0;
    }
    if (daysSinceCommit > 90) {
      return 50.0;
    }
    if (daysSinceCommit > 30) {
      return 75.0;
    }
    return 100.0;
  }

  void _generateRecommendations(List<String> warnings, List<String> recommendations, PackageInfo pkg) {
    if (warnings.isEmpty && recommendations.isEmpty) {
      recommendations.add('Package looks healthy!');
    }
  }
}
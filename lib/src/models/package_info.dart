class PackageInfo {
  final String name;
  final String? version;
  final String? repositoryUrl;
  final DateTime? latestPublished;
  final DateTime? lastCommitDate;
  final int openIssuesCount;
  final int closedIssuesCount;
  final bool isNullSafe;
  final List<String> platforms;
  final String? gitHubRepo;

  const PackageInfo({
    required this.name,
    this.version,
    this.repositoryUrl,
    this.latestPublished,
    this.lastCommitDate,
    this.openIssuesCount = 0,
    this.closedIssuesCount = 0,
    this.isNullSafe = false,
    this.platforms = const [],
    this.gitHubRepo,
  });

  PackageInfo copyWith({
    String? name,
    String? version,
    String? repositoryUrl,
    DateTime? latestPublished,
    DateTime? lastCommitDate,
    int? openIssuesCount,
    int? closedIssuesCount,
    bool? isNullSafe,
    List<String>? platforms,
    String? gitHubRepo,
  }) {
    return PackageInfo(
      name: name ?? this.name,
      version: version ?? this.version,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      latestPublished: latestPublished ?? this.latestPublished,
      lastCommitDate: lastCommitDate ?? this.lastCommitDate,
      openIssuesCount: openIssuesCount ?? this.openIssuesCount,
      closedIssuesCount: closedIssuesCount ?? this.closedIssuesCount,
      isNullSafe: isNullSafe ?? this.isNullSafe,
      platforms: platforms ?? this.platforms,
      gitHubRepo: gitHubRepo ?? this.gitHubRepo,
    );
  }
}

enum RiskLevel { low, medium, high }

class HealthScore {
  final String packageName;
  final int score;
  final RiskLevel riskLevel;
  final Map<String, double> metricScores;
  final List<String> warnings;
  final List<String> recommendations;

  const HealthScore({
    required this.packageName,
    required this.score,
    required this.riskLevel,
    required this.metricScores,
    required this.warnings,
    required this.recommendations,
  });

  static RiskLevel calculateRiskLevel(int score) {
    if (score >= 70) return RiskLevel.low;
    if (score >= 40) return RiskLevel.medium;
    return RiskLevel.high;
  }
}
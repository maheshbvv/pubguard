/// Information about a Flutter/Dart package.
class PackageInfo {
  /// The name of the package.
  final String name;
  /// The latest version.
  final String? version;
  /// The repository URL.
  final String? repositoryUrl;
  /// When the package was last published.
  final DateTime? latestPublished;
  /// When the last commit was made.
  final DateTime? lastCommitDate;
  /// Number of open issues on GitHub.
  final int openIssuesCount;
  /// Number of closed issues on GitHub.
  final int closedIssuesCount;
  /// Whether the package is null-safe.
  final bool isNullSafe;
  /// Supported platforms.
  final List<String> platforms;
  /// GitHub repository path.
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

  /// Creates a copy of this [PackageInfo] with optional overrides.
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

/// Risk level for a package based on health score.
enum RiskLevel { low, medium, high }

/// Health score for a package including metrics and recommendations.
class HealthScore {
  /// Name of the package.
  final String packageName;
  /// Health score (0-100).
  final int score;
  /// Risk level based on score.
  final RiskLevel riskLevel;
  /// Individual metric scores.
  final Map<String, double> metricScores;
  /// Warnings about the package.
  final List<String> warnings;
  /// Recommendations for the package.
  final List<String> recommendations;

  const HealthScore({
    required this.packageName,
    required this.score,
    required this.riskLevel,
    required this.metricScores,
    required this.warnings,
    required this.recommendations,
  });

  /// Calculates [RiskLevel] from a [score].
  static RiskLevel calculateRiskLevel(int score) {
    if (score >= 70) return RiskLevel.low;
    if (score >= 40) return RiskLevel.medium;
    return RiskLevel.high;
  }
}
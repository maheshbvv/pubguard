import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/package_info.dart';

/// Client for fetching GitHub repository data.
class GitHubClient {
  final http.Client _client;
  final String? _token;

  /// Creates a new GitHubClient.
  ///
  /// [client] - Optional HTTP client for making requests.
  /// [token] - Optional GitHub token for API authentication.
  GitHubClient({http.Client? client, String? token})
      : _client = client ?? http.Client(),
        _token = token;

  /// Enriches a [PackageInfo] with GitHub repository data.
  ///
  /// [packageInfo] - The package info to enrich.
  /// [repoPath] - Optional GitHub repository path (e.g., "owner/repo").
  ///             If not provided, tries to infer from repositoryUrl.
  Future<PackageInfo> enrichWithGitHubData(
    PackageInfo packageInfo,
    String? repoPath,
  ) async {
    if (repoPath == null) {
      final inferredRepo = _inferGitHubRepo(packageInfo.repositoryUrl);
      if (inferredRepo == null) return packageInfo;
      return enrichWithGitHubData(packageInfo, inferredRepo);
    }

    try {
      final issuesData = await _fetchIssues(repoPath);
      final commitData = await _fetchLastCommit(repoPath);

      return packageInfo.copyWith(
        openIssuesCount: issuesData['open'] ?? 0,
        closedIssuesCount: issuesData['closed'] ?? 0,
        lastCommitDate: commitData,
        gitHubRepo: repoPath,
      );
    } catch (e) {
      return packageInfo;
    }
  }

  String? _inferGitHubRepo(String? url) {
    if (url == null) return null;
    final match = RegExp(r'github\.com[/:]([^/]+/[^/]+)').firstMatch(url);
    return match?.group(1)?.replaceAll('.git', '');
  }

  Future<Map<String, int>> _fetchIssues(String repo) async {
    final headers = _buildHeaders();
    final response = await _client.get(
      Uri.parse('https://api.github.com/repos/$repo'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      return {'open': 0, 'closed': 0};
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return {
      'open': data['open_issues_count'] ?? 0,
      'closed': data['closed_issues_count'] ?? 0,
    };
  }

  Future<DateTime?> _fetchLastCommit(String repo) async {
    final headers = _buildHeaders();
    final response = await _client.get(
      Uri.parse('https://api.github.com/repos/$repo/commits?per_page=1'),
      headers: headers,
    );

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as List;
    if (data.isEmpty) return null;

    final commit = data[0] as Map<String, dynamic>;
    final commitData = commit['commit'] as Map<String, dynamic>?;
    final author = commitData?['author'] as Map<String, dynamic>?;
    if (author?['date'] == null) return null;

    return DateTime.tryParse(author!['date'].toString());
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
    };
    if (_token != null) {
      headers['Authorization'] = 'token $_token';
    }
    return headers;
  }
}
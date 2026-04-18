import 'dart:convert';
import '../models/package_info.dart';

class OutputFormatter {
  String format(List<HealthScore> scores, {String format = 'table'}) {
    if (format == 'json') {
      return _formatJson(scores);
    }
    return _formatTable(scores);
  }

  String _formatJson(List<HealthScore> scores) {
    final data = scores.map((s) => {
      'package': s.packageName,
      'score': s.score,
      'riskLevel': s.riskLevel.name,
      'warnings': s.warnings,
      'recommendations': s.recommendations,
      'metrics': s.metricScores,
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _formatTable(List<HealthScore> scores) {
    final buffer = StringBuffer();
    buffer.writeln('═' * 80);
    buffer.writeln('${"Package".padRight(25)} ${"Score".padRight(8)} ${"Risk".padRight(10)} ${"Warnings"}');
    buffer.writeln('═' * 80);

    for (final score in scores) {
      final riskLabel = _riskLabel(score.riskLevel);
      final riskColor = _riskColor(score.riskLevel);
      final warnings = score.warnings.take(2).join('; ');
      
      buffer.writeln(
        '${score.packageName.padRight(25)} ${score.score.toString().padRight(8)} '
        '$riskColor${riskLabel.padRight(10)}\x1b[0m ${warnings.isEmpty ? "-" : warnings}',
      );
    }

    buffer.writeln('═' * 80);
    return buffer.toString();
  }

  String _riskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  String _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return '\x1b[32m';
      case RiskLevel.medium:
        return '\x1b[33m';
      case RiskLevel.high:
        return '\x1b[31m';
    }
  }
}
# PubGuard - Plugin Health Monitor for Flutter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Plugin Health Monitor for Flutter - Analyze dependencies and get health scores.

## Features

- **Health Scores**: Calculates 0-100 health scores for Flutter/Dart packages
- **Risk Assessment**: Identifies high-risk, medium-risk, and low-risk dependencies
- **Multiple Data Sources**: Fetches data from pub.dev and GitHub APIs
- **CI Ready**: JSON output for easy integration with CI/CD pipelines

## Installation

```bash
dart pub global activate pubguard
```

Or add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  pubguard: ^1.0.2
```

## Usage

```bash
# Analyze dependencies in current directory
pubguard check

# Analyze a specific pubspec.yaml
pubguard check path/to/pubspec.yaml

# JSON output (for CI)
pubguard check --format json

# Show detailed warnings
pubguard check --warnings
```

### Output Formats

#### Table (default)
```
Package                   Score    Risk       Warnings
════════════════════════════════════════════════════════════════════════════
http                      50       Medium    Has 375 open issues
yaml                      38       High Risk Package not updated in over a year
...
```

#### JSON
```bash
pubguard check --format json
```

```json
[
  {
    "package": "http",
    "score": 50,
    "riskLevel": "medium",
    "warnings": ["Has 375 open issues"]
  }
]
```

## Scoring Metrics

| Metric | Weight | Description |
|--------|--------|-------------|
| Last Update Recency | 25% | Days since last pub.dev release |
| Open Issues | 20% | Number of open GitHub issues |
| Issue Resolution | 10% | Ratio of closed to total issues |
| Platform Support | 15% | Number of supported platforms |
| Null Safety | 10% | Package null safety support |
| GitHub Activity | 20% | Days since last commit |

## Commands

- `pubguard check` - Analyze pubspec.yaml dependencies
- `pubguard audit` - Quick audit of current directory

## License

MIT License - see [LICENSE](LICENSE) for details.
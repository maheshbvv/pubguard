import 'package:args/args.dart';
import 'check_command.dart';

/// CLI command parser and runner for PubGuard.
class Commands {
  static final ArgParser parser = ArgParser(allowTrailingOptions: true)
    ..addCommand('check', ArgParser()
      ..addOption('format', abbr: 'f', allowed: ['table', 'json'], help: 'Output format')
      ..addFlag('warnings', help: 'Show detailed warnings')
      ..addFlag('fail-on-risk', help: 'Exit with error if high-risk packages found')
      ..addFlag('override', help: 'Ignore high-risk failures')
      ..addFlag('verbose', abbr: 'v', help: 'Verbose output')
      ..addFlag('help', abbr: 'h', help: 'Show help')
    )
    ..addCommand('audit', ArgParser()
      ..addOption('format', abbr: 'f', allowed: ['table', 'json'], help: 'Output format')
      ..addFlag('ci', help: 'CI-friendly output')
      ..addFlag('help', abbr: 'h', help: 'Show help')
    );

  static Future<int> run(List<String> args) async {
    try {
      if (args.isEmpty) {
        _printTopLevelHelp();
        return 0;
      }

      final results = parser.parse(args);

      if (results.command == null) {
        _printTopLevelHelp();
        return 1;
      }

      switch (results.command!.name) {
        case 'check':
          if (args.contains('--help') || args.contains('-h')) {
            _printCheckHelp();
            return 0;
          }
          final cmd = CheckCommand();
          await cmd.run(results.command!);
          return 0;
        case 'audit':
          if (args.contains('--help') || args.contains('-h')) {
            _printAuditHelp();
            return 0;
          }
          final cmd = CheckCommand();
          await cmd.run(results.command!);
          return 0;
        default:
          print('Unknown command: ${results.command!.name}');
          return 1;
      }
    } catch (e) {
      print('Error: $e');
      return 1;
    }
  }

  static void _printTopLevelHelp() {
    print('PubGuard - Plugin Health Monitor for Flutter');
    print('');
    print('Usage: pubguard <command> [options]');
    print('');
    print('Commands:');
    print('  check    Analyze pubspec.yaml dependencies');
    print('  audit    Quick audit of current directory');
    print('');
    print('Run "pubguard <command>" for more details');
  }

  static void _printCheckHelp() {
    print('pubguard check - Analyze pubspec.yaml dependencies');
    print('');
    print('Usage: pubguard check [options] [path/to/pubspec.yaml]');
    print('');
    print('Options:');
    print('  -f, --format <table|json>  Output format (default: table)');
    print('  -v, --verbose              Verbose output');
    print('      --warnings            Show detailed warnings');
    print('      --fail-on-risk         Exit with error if high-risk packages found');
    print('      --override             Ignore high-risk failures');
    print('  -h, --help                Show help');
    print('');
    print('Examples:');
    print('  pubguard check                                    # Analyze current directory');
    print('  pubguard check --format json                     # JSON output');
    print('  pubguard check path/to/pubspec.yaml              # Custom path');
  }

  static void _printAuditHelp() {
    print('pubguard audit - Quick audit of current directory');
    print('');
    print('Usage: pubguard audit [options]');
    print('');
    print('Options:');
    print('  -f, --format <table|json>  Output format (default: table)');
    print('      --ci                 CI-friendly output');
    print('  -h, --help                Show help');
  }
}
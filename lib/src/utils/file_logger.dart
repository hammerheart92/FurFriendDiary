// lib/src/utils/file_logger.dart
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Custom logger that writes to both console and file
class FileLogger {
  static Logger? _instance;
  static File? _logFile;

  static Future<Logger> getInstance() async {
    if (_instance != null) return _instance!;

    // Get app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${appDir.path}/logs');

    // Create logs directory if it doesn't exist
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    // Create log file with timestamp
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    _logFile = File('${logsDir.path}/debug_$timestamp.log');

    // Write header to file
    await _logFile!.writeAsString('=== FurFriendDiary Debug Log ===\n');
    await _logFile!.writeAsString('Started: ${DateTime.now()}\n');
    await _logFile!.writeAsString('Log file: ${_logFile!.path}\n\n',
        mode: FileMode.append);

    _instance = Logger(
      printer: _FileAndConsolePrinter(_logFile!),
      level: Level.debug,
    );

    return _instance!;
  }

  static File? get logFile => _logFile;
}

/// Custom printer that writes to both console and file
class _FileAndConsolePrinter extends LogPrinter {
  final File logFile;

  _FileAndConsolePrinter(this.logFile);

  @override
  List<String> log(LogEvent event) {
    final time = DateTime.now().toIso8601String();
    final level = event.level.toString().split('.')[1].toUpperCase();
    final message = event.message;

    final logLine = '[$time] $level: $message';

    // Write to file asynchronously (don't await to avoid blocking)
    logFile.writeAsString('$logLine\n', mode: FileMode.append).catchError((e) {
      print('Error writing to log file: $e');
      return logFile; // Return the file even on error
    });

    // Return for console output
    return [logLine];
  }
}

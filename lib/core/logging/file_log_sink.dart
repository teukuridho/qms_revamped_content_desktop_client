import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'log_record.dart';
import 'log_sink.dart';
import 'log_level.dart';

class FileLogSink implements LogSink {
  static const int _maxBytes = 5 * 1024 * 1024; // 5 MiB
  static const int _maxBackups = 2;

  final File _file;

  final List<String> _buffer = <String>[];
  bool _flushing = false;

  FileLogSink._(this._file);

  String get path => _file.path;

  static Future<FileLogSink?> tryInit({String fileName = 'app.log'}) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final logsDir = Directory(p.join(dir.path, 'logs'));
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final file = File(p.join(logsDir.path, fileName));
      await _rotateIfNeeded(file);
      return FileLogSink._(file);
    } catch (_) {
      // Never crash the app due to logging.
      return null;
    }
  }

  @override
  void write(LogRecord record) {
    final ts = record.timestamp.toIso8601String();
    final msg =
        '[$ts][${record.level.label}][${record.logger}] ${record.message}';
    final err = record.error == null ? '' : ' | error=${record.error}';
    final st = record.stackTrace == null ? '' : '\n${record.stackTrace}';

    _buffer.add('$msg$err$st\n');
    _scheduleFlush();
  }

  void _scheduleFlush() {
    if (_flushing) return;
    _flushing = true;
    scheduleMicrotask(_flush);
  }

  Future<void> _flush() async {
    try {
      if (_buffer.isEmpty) return;
      await _rotateIfNeeded(_file);

      final payload = _buffer.join();
      _buffer.clear();

      // Keep the file handle open only during the write so rotation works on Windows.
      final sink = _file.openWrite(mode: FileMode.append, encoding: utf8);
      sink.write(payload);
      await sink.flush();
      await sink.close();
    } catch (_) {
      // Ignore.
    } finally {
      _flushing = false;
      if (_buffer.isNotEmpty) {
        _scheduleFlush();
      }
    }
  }

  static Future<void> _rotateIfNeeded(File file) async {
    try {
      if (await file.exists()) {
        final len = await file.length();
        if (len < _maxBytes) return;

        // Rotate: app.log.(n-1) -> app.log.n, ..., app.log.1 -> app.log.2, app.log -> app.log.1
        final last = File('${file.path}.$_maxBackups');
        if (await last.exists()) {
          await last.delete();
        }

        for (var i = _maxBackups - 1; i >= 1; i--) {
          final src = File('${file.path}.$i');
          final dst = File('${file.path}.${i + 1}');
          if (await src.exists()) {
            await src.rename(dst.path);
          }
        }

        await file.rename('${file.path}.1');
      }
    } catch (_) {
      // Ignore rotation errors.
    }
  }
}

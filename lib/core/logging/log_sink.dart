import 'log_record.dart';

abstract class LogSink {
  void write(LogRecord record);
}

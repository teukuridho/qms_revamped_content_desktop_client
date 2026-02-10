import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

class InitService {
  static final AppLog _log = AppLog('init');

  late final AppDirectoryService _appDirectoryService;
  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  InitService({
    required AppDirectoryService appDirectoryService,
    required AppDatabaseManager appDatabaseManager,
    required EventManager eventManager,
  }) {
    _appDirectoryService = appDirectoryService;
    _appDatabaseManager = appDatabaseManager;
    _eventManager = eventManager;
  }

  Stream<String> init() async* {
    List<InitProcess> initProcesses = [
      InitProcess("Dotenv", () async {
        await dotenv.load(fileName: ".env");
      }),
      InitProcess("Event manager", () async {
        _eventManager.init();
      }),
      InitProcess("App Directory", () async {
        await _appDirectoryService.init();
      }),
      InitProcess("App Database", () async {
        await _appDatabaseManager.init();
      }),
    ];

    for (var process in initProcesses) {
      yield "Initializing ${process.name}";
      final sw = Stopwatch()..start();
      _log.i('Init step start: ${process.name}');
      try {
        await process.func();
      } catch (ex, st) {
        _log.e('Init step failed: ${process.name}', error: ex, stackTrace: st);
        yield "Exception on ${process.name}: ${ex.toString()}";
        rethrow;
      } finally {
        sw.stop();
        _log.i('Init step done: ${process.name} (${sw.elapsedMilliseconds}ms)');
      }
    }
  }
}

class InitProcess {
  late final String name;
  late final Future Function() func;

  InitProcess(this.name, this.func);
}

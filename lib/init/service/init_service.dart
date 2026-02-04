import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qms_revamped_content_desktop_client/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/event_manager/event_manager.dart';

class InitService {
  late final AppDirectoryService _appDirectoryService;
  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  InitService({
    required AppDirectoryService appDirectoryService,
    required AppDatabaseManager appDatabaseManager,
    required EventManager eventManager
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
      try {
        await process.func();
      }
      catch(ex) {
        yield "Exception on ${process.name}: ${ex.toString()}";
        rethrow;
      }
    }
  }
}

class InitProcess {
  late final String name;
  late final Future Function() func;

  InitProcess(this.name, this.func);
}

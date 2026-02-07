import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppDirectoryService {
  late Directory _appDirectory;

  Future<void> init() async {
    await _createDirectory();
  }

  Future _createDirectory() async {
    String appName = dotenv.env["APP_NAME"]!;
    final documentPath =
        (await path_provider.getApplicationDocumentsDirectory()).path;
    final appDirectoryPath = path.join(documentPath, appName);
    Directory appDirectory = Directory(appDirectoryPath);
    final appDirectoryNotExist = !(await appDirectory.exists());

    if (appDirectoryNotExist) {
      appDirectory = await appDirectory.create();
    }

    // Store app directory
    _appDirectory = appDirectory;
  }

  Directory get appDirectory => _appDirectory;
}

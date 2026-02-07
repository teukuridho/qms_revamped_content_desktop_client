import 'dart:io';

import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:path/path.dart' as path;

class MediaStorageDirectoryService {
  late final AppDirectoryService _appDirectoryService;
  late final String _directoryName;

  late Directory _directory;

  MediaStorageDirectoryService({required AppDirectoryService appDirectoryService, String directoryName = "media"}) {
    _appDirectoryService = appDirectoryService;
    _directoryName = directoryName;
  }

  Future<void> init() async {
    await _createDirectory();
  }

  Future<void> _createDirectory() async {
    Directory appDirectory = _appDirectoryService.appDirectory;
    String mediaDirectoryPath = path.join(appDirectory.path, _directoryName);
    Directory mediaDirectory = Directory(mediaDirectoryPath);

    bool mediaDirectoryNotExist = !(await mediaDirectory.exists());
    if(mediaDirectoryNotExist) {
      await mediaDirectory.create();
    }
  }

  Directory get directory => _directory;

}
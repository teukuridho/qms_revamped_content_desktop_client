import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

class CurrencyExchangeRateFlagStorageDirectoryService {
  static final AppLog _log = AppLog('currency_exchange_rate_flag_storage_dir');

  late final AppDirectoryService _appDirectoryService;
  late final String _directoryName;

  late Directory _directory;

  CurrencyExchangeRateFlagStorageDirectoryService({
    required AppDirectoryService appDirectoryService,
    String directoryName = 'currency_exchange_rate_flags',
  }) {
    _appDirectoryService = appDirectoryService;
    _directoryName = directoryName;
  }

  Future<void> init() async {
    await _createDirectory();
  }

  Future<void> _createDirectory() async {
    final appDirectory = _appDirectoryService.appDirectory;
    final directoryPath = path.join(appDirectory.path, _directoryName);
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      _log.i('Creating currency exchange rate flag directory: $directoryPath');
      await directory.create(recursive: true);
    }
    _directory = directory;
    _log.i('Currency exchange rate flag directory ready: ${_directory.path}');
  }

  Directory get directory => _directory;
}

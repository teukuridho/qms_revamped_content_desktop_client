import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/directory/media_storage_directory_service.dart';

class MediaStorageFileService {
  static final AppLog _log = AppLog('media_storage_file');

  final MediaStorageDirectoryService _dir;

  MediaStorageFileService({
    required MediaStorageDirectoryService directoryService,
  }) : _dir = directoryService;

  /// Returns a stable local file path for a remote media id + fileName.
  File fileFor({required int remoteId, required String fileName}) {
    final safe = _safeFileName(remoteId: remoteId, fileName: fileName);
    return File(p.join(_dir.directory.path, safe));
  }

  Future<void> deleteIfExists(String filePath) async {
    final f = File(filePath);
    if (!await f.exists()) return;
    _log.i('Deleting file: $filePath');
    await f.delete();
  }

  static String _safeFileName({
    required int remoteId,
    required String fileName,
  }) {
    final raw = fileName.trim().isEmpty ? 'media' : fileName.trim();
    final normalized = raw.replaceAll('\\', '/').split('/').last;
    final safe = normalized.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return '${remoteId}_$safe';
  }
}

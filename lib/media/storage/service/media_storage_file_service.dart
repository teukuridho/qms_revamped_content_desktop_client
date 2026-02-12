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

    // Windows is sensitive to long filenames and long paths. Keep the final
    // basename reasonably short while preserving extension when present.
    final prefix = '${remoteId}_';
    final ext = p.extension(safe);
    final base = ext.isEmpty ? safe : p.basenameWithoutExtension(safe);

    const maxFileNameLen = 180; // conservative; avoids common Windows limits
    final maxBaseLen = (maxFileNameLen - prefix.length - ext.length)
        .clamp(16, maxFileNameLen);
    final clippedBase = base.length <= maxBaseLen
        ? base
        : base.substring(0, maxBaseLen);

    return '$prefix$clippedBase$ext';
  }
}

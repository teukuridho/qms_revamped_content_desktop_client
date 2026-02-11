import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/directory/currency_exchange_rate_flag_storage_directory_service.dart';

class CurrencyExchangeRateFlagStorageFileService {
  static final AppLog _log = AppLog('currency_exchange_rate_flag_storage_file');

  final CurrencyExchangeRateFlagStorageDirectoryService _directoryService;

  CurrencyExchangeRateFlagStorageFileService({
    required CurrencyExchangeRateFlagStorageDirectoryService directoryService,
  }) : _directoryService = directoryService;

  File fileFor({required int remoteFlagImageId, required String extension}) {
    final safeExtension = _normalizeExtension(extension);
    final fileName = 'flag_$remoteFlagImageId$safeExtension';
    return File(p.join(_directoryService.directory.path, fileName));
  }

  Future<bool> exists(String filePath) async {
    return File(filePath).exists();
  }

  Future<String> writeFlagImage({
    required int remoteFlagImageId,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final extension = extensionFromMimeType(mimeType);
    final destination = fileFor(
      remoteFlagImageId: remoteFlagImageId,
      extension: extension,
    );
    await destination.parent.create(recursive: true);

    await _deleteStaleVariants(
      remoteFlagImageId: remoteFlagImageId,
      keepPath: destination.path,
    );

    final tmp = File('${destination.path}.part');
    if (await tmp.exists()) {
      await tmp.delete();
    }

    await tmp.writeAsBytes(bytes, flush: true);
    if (await destination.exists()) {
      await destination.delete();
    }
    await tmp.rename(destination.path);
    return destination.path;
  }

  Future<void> deleteIfExists(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    _log.i('Deleting flag file: $filePath');
    await file.delete();
  }

  Future<void> _deleteStaleVariants({
    required int remoteFlagImageId,
    required String keepPath,
  }) async {
    final prefix = 'flag_$remoteFlagImageId.';
    final dir = _directoryService.directory;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!name.startsWith(prefix)) continue;
      if (entity.path == keepPath) continue;
      _log.d('Removing stale flag variant: ${entity.path}');
      await entity.delete();
    }
  }

  static String extensionFromMimeType(String mimeType) {
    final normalized = mimeType.toLowerCase().trim();
    if (normalized.contains('image/png')) return '.png';
    if (normalized.contains('image/jpeg')) return '.jpg';
    if (normalized.contains('image/jpg')) return '.jpg';
    if (normalized.contains('image/webp')) return '.webp';
    if (normalized.contains('image/gif')) return '.gif';
    if (normalized.contains('image/svg+xml')) return '.svg';
    if (normalized.contains('image/bmp')) return '.bmp';
    return '.bin';
  }

  static String _normalizeExtension(String extension) {
    final trimmed = extension.trim();
    if (trimmed.isEmpty) return '.bin';
    if (trimmed.startsWith('.')) return trimmed;
    return '.$trimmed';
  }
}

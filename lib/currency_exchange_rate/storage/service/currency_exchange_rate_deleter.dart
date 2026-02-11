import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/service/currency_exchange_rate_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/service/currency_exchange_rate_deleter_base.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/service/currency_exchange_rate_flag_storage_file_service.dart';

class CurrencyExchangeRateDeleter implements CurrencyExchangeRateDeleterBase {
  static final AppLog _log = AppLog('currency_exchange_rate_deleter');

  final String tag;
  final CurrencyExchangeRateRegistryService _registryService;
  final CurrencyExchangeRateFlagStorageFileService _flagStorageFileService;

  CurrencyExchangeRateDeleter({
    required this.tag,
    required CurrencyExchangeRateRegistryService registryService,
    required CurrencyExchangeRateFlagStorageFileService flagStorageFileService,
  }) : _registryService = registryService,
       _flagStorageFileService = flagStorageFileService;

  @override
  Future<void> deleteLocalByRemoteId(int remoteId) async {
    final existing = await _registryService.getOneByRemoteId(
      remoteId: remoteId,
      tag: tag,
    );
    if (existing == null) return;

    final path = existing.flagImagePath;
    if (path != null && path.isNotEmpty) {
      _log.i('Deleting flag file while deleting row: $path');
      await _flagStorageFileService.deleteIfExists(path);
    }
    await _registryService.delete(existing.id);
  }
}

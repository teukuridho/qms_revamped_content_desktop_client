import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/agent/currency_exchange_rate_agent.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/currency_exchange_rate_downloader.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/position_update/currency_exchange_rate_position_update_listener.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/service/currency_exchange_rate_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/directory/currency_exchange_rate_flag_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/service/currency_exchange_rate_deleter.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/service/currency_exchange_rate_flag_storage_file_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/synchronizer/currency_exchange_rate_synchronizer.dart';

class CurrencyExchangeRateFeature {
  final CurrencyExchangeRateRegistryService registryService;
  final CurrencyExchangeRateFlagStorageFileService flagStorageFileService;
  final CurrencyExchangeRateDownloader downloader;
  final CurrencyExchangeRateDeleter deleter;
  final CurrencyExchangeRateSynchronizer synchronizer;
  final CurrencyExchangeRatePositionUpdateListener positionUpdateListener;
  final CurrencyExchangeRateAgent agent;

  CurrencyExchangeRateFeature._({
    required this.registryService,
    required this.flagStorageFileService,
    required this.downloader,
    required this.deleter,
    required this.synchronizer,
    required this.positionUpdateListener,
    required this.agent,
  });

  factory CurrencyExchangeRateFeature.create({
    required String serviceName,
    required String tag,
    required EventManager eventManager,
    required AppDatabaseManager appDatabaseManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    required CurrencyExchangeRateFlagStorageDirectoryService
    flagStorageDirectoryService,
  }) {
    final registryService = CurrencyExchangeRateRegistryService(
      appDatabaseManager: appDatabaseManager,
      eventManager: eventManager,
    );

    final flagStorageFileService = CurrencyExchangeRateFlagStorageFileService(
      directoryService: flagStorageDirectoryService,
    );

    final downloader = CurrencyExchangeRateDownloader(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      registryService: registryService,
      flagStorageFileService: flagStorageFileService,
    );

    final deleter = CurrencyExchangeRateDeleter(
      tag: tag,
      registryService: registryService,
      flagStorageFileService: flagStorageFileService,
    );

    final synchronizer = CurrencyExchangeRateSynchronizer(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      downloader: downloader,
      deleter: deleter,
    );

    final positionUpdateListener = CurrencyExchangeRatePositionUpdateListener(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      registryService: registryService,
    );

    final authService = OidcAuthService(
      serviceName: serviceName,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
    );

    final agent = CurrencyExchangeRateAgent(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      directoryService: flagStorageDirectoryService,
      authService: authService,
      downloader: downloader,
      synchronizer: synchronizer,
      positionUpdateListener: positionUpdateListener,
    );

    return CurrencyExchangeRateFeature._(
      registryService: registryService,
      flagStorageFileService: flagStorageFileService,
      downloader: downloader,
      deleter: deleter,
      synchronizer: synchronizer,
      positionUpdateListener: positionUpdateListener,
      agent: agent,
    );
  }
}

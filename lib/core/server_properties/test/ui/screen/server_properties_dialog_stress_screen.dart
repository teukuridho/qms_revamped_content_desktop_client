import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_configuration_dialog.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/create_server_properties_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/update_service_by_name_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class ServerPropertiesDialogStressScreen extends StatefulWidget {
  static const openDialogButtonKey = ValueKey<String>(
    'stress_open_server_properties_dialog_button',
  );
  static const runAutoButtonKey = ValueKey<String>(
    'stress_run_server_properties_dialog_cycles_button',
  );
  static const dialogKey = ValueKey<String>('stress_server_properties_dialog');

  final int autoCycles;

  const ServerPropertiesDialogStressScreen({super.key, this.autoCycles = 40});

  @override
  State<ServerPropertiesDialogStressScreen> createState() =>
      _ServerPropertiesDialogStressScreenState();
}

class _ServerPropertiesDialogStressScreenState
    extends State<ServerPropertiesDialogStressScreen> {
  static const _serviceName = 'stress-server-properties';
  static const _tag = 'main';

  final _registryService = _FakeServerPropertiesRegistryService();
  bool _running = false;
  int _completedCycles = 0;
  String _status = 'Idle';
  final _eventManager = EventManager();

  Future<void> _openDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ServerPropertiesConfigurationDialog(
          dialogKey: ServerPropertiesDialogStressScreen.dialogKey,
          serviceName: _serviceName,
          tag: _tag,
          title: 'Server Properties Stress Dialog',
          description:
              'Press Esc repeatedly or run auto cycles to stress route/dialog teardown.',
          registryService: _registryService,
          eventManager: _eventManager,
        );
      },
    );
  }

  Future<void> _runAutoCycles() async {
    if (_running) return;
    setState(() {
      _running = true;
      _completedCycles = 0;
      _status = 'Running ${widget.autoCycles} cycles...';
    });

    var failedAt = -1;
    try {
      for (var i = 0; i < widget.autoCycles; i++) {
        if (!mounted) return;

        final dialogFuture = _openDialog();
        await Future<void>.delayed(const Duration(milliseconds: 90));

        if (!mounted) return;
        await Navigator.of(context, rootNavigator: true).maybePop();
        await dialogFuture.timeout(const Duration(seconds: 2));
        await Future<void>.delayed(const Duration(milliseconds: 35));

        if (!mounted) return;
        setState(() {
          _completedCycles = i + 1;
        });
      }
    } catch (_) {
      failedAt = _completedCycles + 1;
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
          _status = failedAt < 0
              ? 'Done: $_completedCycles/${widget.autoCycles} cycles'
              : 'Stopped at cycle $failedAt';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Properties Dialog Stress Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use this screen to reproduce dialog teardown crashes. For manual repro, open the dialog and press Esc repeatedly.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  key: ServerPropertiesDialogStressScreen.openDialogButtonKey,
                  onPressed: _running ? null : _openDialog,
                  child: const Text('Open Stress Dialog'),
                ),
                OutlinedButton(
                  key: ServerPropertiesDialogStressScreen.runAutoButtonKey,
                  onPressed: _running ? null : _runAutoCycles,
                  child: Text('Run Auto (${widget.autoCycles})'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Completed cycles: $_completedCycles'),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}

class _FakeServerPropertiesRegistryService
    extends ServerPropertiesRegistryService {
  _FakeServerPropertiesRegistryService()
    : super(
        appDatabaseManager: AppDatabaseManager(
          appDirectoryService: AppDirectoryService(),
        ),
        eventManager: EventManager(),
      );

  ServerProperty _state = const ServerProperty(
    id: 1,
    serviceName: _ServerPropertiesDialogStressScreenState._serviceName,
    tag: _ServerPropertiesDialogStressScreenState._tag,
    serverAddress: 'http://localhost:8081',
    keycloakBaseUrl: 'https://id.example.com',
    keycloakRealm: 'master',
    keycloakClientId: 'qms-desktop-client',
    oidcAccessToken: '',
    oidcRefreshToken: '',
    oidcIdToken: '',
    oidcExpiresAtEpochMs: 0,
    oidcScope: '',
    oidcTokenType: '',
  );

  @override
  Future<ServerProperty?> getOneByServiceNameAndTag({
    required String serviceName,
    required String tag,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_state.serviceName != serviceName || _state.tag != tag) return null;
    return _state;
  }

  @override
  Future<ServerProperty> create(CreateServerPropertiesRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    _state = _state.copyWith(
      serviceName: request.serviceName,
      tag: request.tag,
      serverAddress: request.serverAddress,
      keycloakBaseUrl: request.keycloakBaseUrl,
      keycloakRealm: request.keycloakRealm,
      keycloakClientId: request.keycloakClientId,
    );
    return _state;
  }

  @override
  Future<ServerProperty?> updateByServiceNameAndTag(
    UpdateServiceByNameRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (_state.serviceName != request.serviceName ||
        _state.tag != request.tag) {
      return null;
    }

    _state = _state.copyWith(
      serverAddress: request.serverAddress ?? _state.serverAddress,
      keycloakBaseUrl: request.keycloakBaseUrl ?? _state.keycloakBaseUrl,
      keycloakRealm: request.keycloakRealm ?? _state.keycloakRealm,
      keycloakClientId: request.keycloakClientId ?? _state.keycloakClientId,
      oidcAccessToken: request.oidcAccessToken ?? _state.oidcAccessToken,
      oidcRefreshToken: request.oidcRefreshToken ?? _state.oidcRefreshToken,
      oidcIdToken: request.oidcIdToken ?? _state.oidcIdToken,
      oidcExpiresAtEpochMs:
          request.oidcExpiresAtEpochMs ?? _state.oidcExpiresAtEpochMs,
      oidcScope: request.oidcScope ?? _state.oidcScope,
      oidcTokenType: request.oidcTokenType ?? _state.oidcTokenType,
    );
    return _state;
  }
}

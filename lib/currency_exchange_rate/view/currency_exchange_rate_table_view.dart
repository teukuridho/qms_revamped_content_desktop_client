import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/view_model/auth_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_form_view.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/event/currency_exchange_rate_download_events.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/service/currency_exchange_rate_registry_service.dart';

enum _CurrencyExchangeRateContextAction { configure, reinitialize }

class CurrencyExchangeRateTableView extends StatefulWidget {
  final String serviceName;
  final String tag;
  final EventManager eventManager;
  final ServerPropertiesRegistryService serverPropertiesRegistryService;
  final CurrencyExchangeRateRegistryService registryService;
  final Future<void> Function()? onReinitializeRequested;

  const CurrencyExchangeRateTableView({
    super.key,
    required this.serviceName,
    required this.tag,
    required this.eventManager,
    required this.serverPropertiesRegistryService,
    required this.registryService,
    this.onReinitializeRequested,
  });

  @override
  State<CurrencyExchangeRateTableView> createState() =>
      _CurrencyExchangeRateTableViewState();
}

class _CurrencyExchangeRateTableViewState
    extends State<CurrencyExchangeRateTableView> {
  StreamSubscription<CurrencyExchangeRateDownloadStartedEvent>? _dlStartSub;
  StreamSubscription<CurrencyExchangeRateDownloadSucceededEvent>? _dlOkSub;
  StreamSubscription<CurrencyExchangeRateDownloadFailedEvent>? _dlFailSub;
  bool _reinitializeInProgress = false;

  @override
  void initState() {
    super.initState();

    _dlStartSub = widget.eventManager
        .listen<CurrencyExchangeRateDownloadStartedEvent>()
        .listen((e) {
          if (e.serviceName != widget.serviceName || e.tag != widget.tag) {
            return;
          }
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Syncing currency exchange rates...'),
              duration: Duration(days: 1),
            ),
          );
        });

    _dlOkSub = widget.eventManager
        .listen<CurrencyExchangeRateDownloadSucceededEvent>()
        .listen((e) {
          if (e.serviceName != widget.serviceName || e.tag != widget.tag) {
            return;
          }
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Sync complete (${e.syncedCount} rows)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        });

    _dlFailSub = widget.eventManager
        .listen<CurrencyExchangeRateDownloadFailedEvent>()
        .listen((e) {
          if (e.serviceName != widget.serviceName || e.tag != widget.tag) {
            return;
          }
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${e.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        });
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _dlStartSub?.cancel();
    // ignore: discarded_futures
    _dlOkSub?.cancel();
    // ignore: discarded_futures
    _dlFailSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = StreamBuilder<List<CurrencyExchangeRate>>(
      stream: widget.registryService.watchAllByTagOrdered(tag: widget.tag),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? const <CurrencyExchangeRate>[];
        if (rows.isEmpty) {
          return const Center(child: Text('No currency exchange rates'));
        }

        return _buildTable(rows);
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) => _showContextMenu(details.globalPosition),
      child: content,
    );
  }

  Widget _buildTable(List<CurrencyExchangeRate> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('FLAG')),
                  DataColumn(label: Text('COUNTRY NAME')),
                  DataColumn(label: Text('CURRENCY_CODE')),
                  DataColumn(label: Text('BUY')),
                  DataColumn(label: Text('SELL')),
                ],
                rows: rows
                    .map(
                      (row) => DataRow(
                        cells: [
                          DataCell(_buildFlag(row.flagImagePath)),
                          DataCell(Text(row.countryName)),
                          DataCell(Text(row.currencyCode)),
                          DataCell(Text(_formatFixedAmount(row.buy))),
                          DataCell(Text(_formatFixedAmount(row.sell))),
                        ],
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlag(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return const Icon(Icons.flag_outlined);
    }
    return SizedBox(
      width: 32,
      height: 24,
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined),
      ),
    );
  }

  static String _formatFixedAmount(double value) {
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts.first;
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    final grouped = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final left = intPart.length - i;
      grouped.write(intPart[i]);
      if (left > 1 && left % 3 == 1) {
        grouped.write(',');
      }
    }

    final prefix = negative ? '-' : '';
    return '$prefix${grouped.toString()}.$decimalPart';
  }

  Future<void> _showContextMenu(Offset globalPosition) async {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final renderObject = overlay.context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final overlayBox = renderObject;
    final action = await showMenu<_CurrencyExchangeRateContextAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlayBox.size,
      ),
      items: [
        const PopupMenuItem<_CurrencyExchangeRateContextAction>(
          value: _CurrencyExchangeRateContextAction.configure,
          child: Text('Configure Server & Auth'),
        ),
        PopupMenuItem<_CurrencyExchangeRateContextAction>(
          value: _CurrencyExchangeRateContextAction.reinitialize,
          enabled:
              !_reinitializeInProgress &&
              widget.onReinitializeRequested != null,
          child: Text(
            _reinitializeInProgress
                ? 'Reinitializing...'
                : 'Reinitialize Currency Exchange Rates',
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _CurrencyExchangeRateContextAction.configure:
        await _openConfigurationDialog();
        break;
      case _CurrencyExchangeRateContextAction.reinitialize:
        await _reinitialize();
        break;
    }
  }

  Future<void> _openConfigurationDialog() async {
    final formViewModel = ServerPropertiesFormViewModel(
      registryService: widget.serverPropertiesRegistryService,
      serviceName: widget.serviceName,
    );
    final authViewModel = AuthViewModel(
      authService: OidcAuthService(
        serviceName: widget.serviceName,
        serverPropertiesRegistryService: widget.serverPropertiesRegistryService,
        eventManager: widget.eventManager,
      ),
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              width: 640,
              height: 760,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Currency Exchange Rate Configuration',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configure server connection and authentication for this currency exchange rate component.',
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ServerPropertiesFormView(
                        viewModel: formViewModel,
                        authViewModel: authViewModel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      formViewModel.dispose();
      authViewModel.dispose();
    }
  }

  Future<void> _reinitialize() async {
    final callback = widget.onReinitializeRequested;
    if (callback == null || _reinitializeInProgress) return;

    setState(() {
      _reinitializeInProgress = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      await callback();
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Currency exchange rates reinitialized'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to reinitialize currency exchange rates: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reinitializeInProgress = false;
        });
      }
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_configuration_dialog.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/core/utility/looping_vertical_auto_scroll.dart';
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
  static const double _minTableWidth = 900;
  static const double _headerRowHeight = 46;
  static const double _bodyRowHeight = 54;
  static const double _bodyDividerWidth = 1;
  static const int _infiniteLoopCopies = 5;
  static const int _infiniteWrapBufferRows = 3;
  static const double _autoScrollStep = 1.2;
  static const Duration _autoScrollReferenceTick = Duration(milliseconds: 32);

  static const Map<int, TableColumnWidth> _tableColumnWidths =
      <int, TableColumnWidth>{
        0: FixedColumnWidth(90),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(2),
      };

  StreamSubscription<CurrencyExchangeRateDownloadStartedEvent>? _dlStartSub;
  StreamSubscription<CurrencyExchangeRateDownloadSucceededEvent>? _dlOkSub;
  StreamSubscription<CurrencyExchangeRateDownloadFailedEvent>? _dlFailSub;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  late final AutoScrollCoordinator _verticalAutoScrollCoordinator;
  bool _reinitializeInProgress = false;
  bool _shouldAutoScroll = false;
  bool _useInfiniteLoop = false;
  double _infiniteCycleExtent = 0;
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    _verticalAutoScrollCoordinator = LoopingVerticalAutoScrollCoordinator(
      controller: _verticalScrollController,
      tickDuration: _autoScrollReferenceTick,
      step: _autoScrollStep,
      resetToStartWhenAtMaxExtent: false,
      shouldRun: (_) => _shouldAutoScroll,
      nextOffset: (position, step) {
        final raw = position.pixels + step;
        if (!_useInfiniteLoop || _infiniteCycleExtent <= 0) {
          return raw;
        }

        final wrapBufferExtent =
            _infiniteWrapBufferRows * (_bodyRowHeight + _bodyDividerWidth);
        final desiredThreshold = (_infiniteCycleExtent * 3) - wrapBufferExtent;
        final maxAllowedThreshold = position.maxScrollExtent - wrapBufferExtent;
        final wrapThreshold = math.max(
          _infiniteCycleExtent,
          math.min(desiredThreshold, maxAllowedThreshold),
        );
        if (raw >= wrapThreshold) {
          return raw - _infiniteCycleExtent;
        }
        return raw;
      },
    )..attach();

    _dlStartSub = widget.eventManager
        .listen<CurrencyExchangeRateDownloadStartedEvent>()
        .listen((e) {
          if (e.serviceName != widget.serviceName || e.tag != widget.tag) {
            return;
          }
          if (!mounted) return;
          final messenger = _messenger;
          if (messenger == null || !messenger.mounted) return;
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
          final messenger = _messenger;
          if (messenger == null || !messenger.mounted) return;
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
          final messenger = _messenger;
          if (messenger == null || !messenger.mounted) return;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _verticalAutoScrollCoordinator.detach();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
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
    _verticalAutoScrollCoordinator.scheduleSync();

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
        final tableWidth = math.max(constraints.maxWidth, _minTableWidth);
        final tableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : (_headerRowHeight + (rows.length * _bodyRowHeight));
        final bodyViewportHeight = math.max(
          0,
          tableHeight - _headerRowHeight - _bodyDividerWidth,
        );
        final originalBodyExtent = _estimateBodyExtent(rows.length);
        final shouldAutoScroll = originalBodyExtent > bodyViewportHeight;
        final useInfiniteLoop =
            shouldAutoScroll && rows.isNotEmpty && _infiniteLoopCopies > 1;
        final infiniteCycleExtent = useInfiniteLoop
            ? _estimateCycleExtent(rows.length)
            : 0.0;
        final visibleRows = useInfiniteLoop
            ? _buildInfiniteLoopRows(rows)
            : rows;

        _shouldAutoScroll = shouldAutoScroll;
        _useInfiniteLoop = useInfiniteLoop;
        _infiniteCycleExtent = infiniteCycleExtent;
        _verticalAutoScrollCoordinator.scheduleSync();
        final verticalBodyScrollView = SingleChildScrollView(
          controller: _verticalScrollController,
          child: _buildBodyTable(visibleRows),
        );
        final verticalBodyWithoutAutoScrollbar = ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: verticalBodyScrollView,
        );
        final verticalScrollable = _useInfiniteLoop
            ? verticalBodyWithoutAutoScrollbar
            : Scrollbar(
                controller: _verticalScrollController,
                thumbVisibility: true,
                child: verticalBodyWithoutAutoScrollbar,
              );

        return NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _verticalAutoScrollCoordinator.onScrollMetricsChanged();
            return false;
          },
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                height: tableHeight,
                child: Column(
                  children: [
                    _buildHeaderRow(context),
                    const Divider(height: 1),
                    Expanded(child: verticalScrollable),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Table(
        columnWidths: _tableColumnWidths,
        children: const [
          TableRow(
            children: [
              _TableHeaderCell(label: 'FLAG'),
              _TableHeaderCell(label: 'COUNTRY NAME'),
              _TableHeaderCell(label: 'CURRENCY CODE'),
              _TableHeaderCell(label: 'BUY', alignment: Alignment.centerRight),
              _TableHeaderCell(label: 'SELL', alignment: Alignment.centerRight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTable(List<CurrencyExchangeRate> rows) {
    final divider = Divider.createBorderSide(context, width: 1);

    return Table(
      columnWidths: _tableColumnWidths,
      border: TableBorder(horizontalInside: divider),
      children: rows
          .map(
            (row) => TableRow(
              children: [
                _buildBodyCell(_buildFlag(row.flagImagePath)),
                _buildBodyCell(Text(row.countryName)),
                _buildBodyCell(Text(row.currencyCode)),
                _buildBodyCell(
                  Text(_formatFixedAmount(row.buy), textAlign: TextAlign.right),
                  alignment: Alignment.centerRight,
                ),
                _buildBodyCell(
                  Text(
                    _formatFixedAmount(row.sell),
                    textAlign: TextAlign.right,
                  ),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildBodyCell(
    Widget child, {
    Alignment alignment = Alignment.centerLeft,
  }) {
    return SizedBox(
      height: _bodyRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }

  List<CurrencyExchangeRate> _buildInfiniteLoopRows(
    List<CurrencyExchangeRate> rows,
  ) {
    final loopRowCount = rows.length * _infiniteLoopCopies;
    return List<CurrencyExchangeRate>.generate(
      loopRowCount,
      (index) => rows[index % rows.length],
      growable: false,
    );
  }

  double _estimateBodyExtent(int rowCount) {
    if (rowCount <= 0) return 0;
    return (rowCount * _bodyRowHeight) + ((rowCount - 1) * _bodyDividerWidth);
  }

  double _estimateCycleExtent(int rowCount) {
    if (rowCount <= 0) return 0;
    // A full cycle includes one trailing divider to bridge into the next copy.
    return rowCount * (_bodyRowHeight + _bodyDividerWidth);
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

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final renderObject = overlay.context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        !renderObject.attached) {
      return;
    }
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
    await showDialog<void>(
      context: context,
      builder: (context) {
        return ServerPropertiesConfigurationDialog(
          serviceName: widget.serviceName,
          title: 'Currency Exchange Rate Configuration',
          description:
              'Configure server connection and authentication for this currency exchange rate component.',
          registryService: widget.serverPropertiesRegistryService,
          eventManager: widget.eventManager,
        );
      },
    );
  }

  Future<void> _reinitialize() async {
    final callback = widget.onReinitializeRequested;
    if (callback == null || _reinitializeInProgress) return;

    setState(() {
      _reinitializeInProgress = true;
    });

    final messenger = _messenger;
    try {
      await callback();
      if (!mounted) return;
      if (messenger != null && messenger.mounted) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Currency exchange rates reinitialized'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (messenger != null && messenger.mounted) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to reinitialize currency exchange rates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _reinitializeInProgress = false;
        });
      }
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;
  final Alignment alignment;

  const _TableHeaderCell({
    required this.label,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _CurrencyExchangeRateTableViewState._headerRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Align(
          alignment: alignment,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

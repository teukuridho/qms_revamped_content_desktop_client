import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/config/app_config.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/core/settings/service/app_settings_service.dart';
import 'package:qms_revamped_content_desktop_client/core/settings/ui/settings_dialog.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/agent/currency_exchange_rate_feature.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/view/currency_exchange_rate_table_view.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_feature.dart';
import 'package:qms_revamped_content_desktop_client/media/player/ui/media_player_view.dart';
import 'package:qms_revamped_content_desktop_client/product/agent/product_features.dart';
import 'package:qms_revamped_content_desktop_client/product/view/product_table_view.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  final String branchName;

  const MainScreen({super.key, this.branchName = 'KCP MEDAN MALL'});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySavedFullscreenIfNeeded();
    });
  }

  bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  Future<void> _applySavedFullscreenIfNeeded() async {
    if (!_isDesktop || !mounted) return;

    final settings = context.read<AppSettingsService>();
    final enabled = await settings.getFullscreenEnabled();

    try {
      final current = await windowManager.isFullScreen();
      if (current == enabled) return;
      await windowManager.setFullScreen(enabled);
    } catch (_) {
      // Ignore (e.g. unsupported platform/window not ready).
    }
  }

  Future<void> _openSettings() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaFeature = context.read<MediaFeature>();
    final currencyFeature = context.read<CurrencyExchangeRateFeature>();
    final productFeatures = context.read<ProductFeatures>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padH = (constraints.maxWidth * 0.05).clamp(18.0, 64.0);
          final padV = (constraints.maxHeight * 0.025).clamp(16.0, 48.0);
          final gap = (constraints.maxHeight * 0.012).clamp(10.0, 18.0);

          // Percentage sizing to match the reference proportions.
          final contentH = (constraints.maxHeight - (padV * 2)).clamp(0.0, 1e9);
          final gapsH = gap * 4;
          final usableH = (contentH - gapsH).clamp(0.0, 1e9);
          // Requested split:
          // - header: 10%
          // - media: 25%
          // - product: 20%
          // - exchange rate: 25%
          // - clock/date: 20%
          final headerH = usableH * 0.10;
          final mediaH = usableH * 0.30;
          final productH = usableH * 0.23;
          final currencyH = usableH * 0.29;
          final clockH = usableH * 0.08;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/bg.jpg', fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padH,
                    vertical: padV,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: headerH,
                        child: _Header(
                          branchName: widget.branchName,
                          onSettingsRequested: _openSettings,
                        ),
                      ),
                      SizedBox(height: gap),
                      SizedBox(
                        height: mediaH,
                        child: _FramedPanel(
                          backgroundColor: Colors.white,
                          child: MediaPlayerView(
                            serviceName: AppConfig.mediaServiceName,
                            tag: AppConfig.mediaTag,
                            eventManager: context.read<EventManager>(),
                            serverPropertiesRegistryService: context
                                .read<ServerPropertiesRegistryService>(),
                            controller: mediaFeature.playerController,
                            onReinitializeRequested: () async {
                              await mediaFeature.agent.reinit(
                                autoPlay: true,
                                startSynchronizer: true,
                              );
                              await mediaFeature.playerController.playFromFirst(
                                reason: 'main_screen_reinitialize_media',
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: gap),
                      SizedBox(
                        height: productH,
                        child: Row(
                          children: [
                            Expanded(
                              child: ProductTableView(
                                serviceName: AppConfig.productServiceName,
                                tag: AppConfig.productTag,
                                nameHeader: 'DEPOSITO RP',
                                valueHeader: 'Suk. Bung (% p.a)',
                                eventManager: context.read<EventManager>(),
                                serverPropertiesRegistryService: context
                                    .read<ServerPropertiesRegistryService>(),
                                registryService:
                                    productFeatures.main.registryService,
                                onReinitializeRequested: () async {
                                  await productFeatures.main.agent.reinit(
                                    startSynchronizer: true,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: ProductTableView(
                                serviceName: AppConfig.productServiceName,
                                tag: AppConfig.productSecondTag,
                                nameHeader: 'PINJAMAN',
                                valueHeader: 'Suku Bunga (% p.a)',
                                eventManager: context.read<EventManager>(),
                                serverPropertiesRegistryService: context
                                    .read<ServerPropertiesRegistryService>(),
                                registryService:
                                    productFeatures.second.registryService,
                                onReinitializeRequested: () async {
                                  await productFeatures.second.agent.reinit(
                                    startSynchronizer: true,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      SizedBox(
                        height: currencyH,
                        child: CurrencyExchangeRateTableView(
                          serviceName:
                              AppConfig.currencyExchangeRateServiceName,
                          tag: AppConfig.currencyExchangeRateTag,
                          eventManager: context.read<EventManager>(),
                          serverPropertiesRegistryService: context
                              .read<ServerPropertiesRegistryService>(),
                          registryService: currencyFeature.registryService,
                          onReinitializeRequested: () async {
                            await currencyFeature.agent.reinit(
                              startSynchronizer: true,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: gap),
                      SizedBox(
                        height: clockH,
                        child: const Center(child: _SystemClockAndDate()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum _MainHeaderContextAction { settings }

class _Header extends StatelessWidget {
  final String branchName;
  final Future<void> Function() onSettingsRequested;

  const _Header({required this.branchName, required this.onSettingsRequested});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, details.globalPosition),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final logoH = (h * 0.52).clamp(44.0, 110.0);
          // Reserve a little vertical space so the branch name doesn't feel cramped.
          final reservedGap = (h * 0.04).clamp(4.0, 10.0);
          final textSize = (h * 0.5).clamp(18.0, 40.0);

          final text = branchName.toUpperCase();
          final fittedSize = _fitFontSize(
            text: text,
            baseStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [Shadow(color: Color(0x88000000), blurRadius: 18)],
            ),
            minFontSize: 14,
            maxFontSize: textSize,
            maxWidth: constraints.maxWidth,
            maxHeight: h - logoH - reservedGap,
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo-bri-terbaru.png', height: logoH),
              // SizedBox(height: gap),
              Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: fittedSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: const [
                    Shadow(color: Color(0x88000000), blurRadius: 18),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    Offset globalPosition,
  ) async {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final renderObject = overlay.context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        !renderObject.attached) {
      return;
    }
    final overlayBox = renderObject;

    final action = await showMenu<_MainHeaderContextAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlayBox.size,
      ),
      items: const [
        PopupMenuItem<_MainHeaderContextAction>(
          value: _MainHeaderContextAction.settings,
          child: Text('Settings'),
        ),
      ],
    );

    if (action == null) return;
    switch (action) {
      case _MainHeaderContextAction.settings:
        await onSettingsRequested();
        break;
    }
  }
}

class _FramedPanel extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _FramedPanel({required this.child, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: const Color(0xFF0A3C86), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _SystemClockAndDate extends StatefulWidget {
  const _SystemClockAndDate();

  @override
  State<_SystemClockAndDate> createState() => _SystemClockAndDateState();
}

class _SystemClockAndDateState extends State<_SystemClockAndDate> {
  static const _digitalFamily = 'Digital7';
  DateTime _now = DateTime.now();
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');

    final timeText = '$hh:$mm:$ss';
    final dateText = _formatDateIdUpper(_now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final gap = (h * 0.01).clamp(6.0, 14.0);
        final timeMaxSize = (h * 0.62).clamp(44.0, 160.0);
        final dateMaxSize = (h * 0.16).clamp(12.0, 42.0);

        final timeSize = _fitFontSize(
          text: timeText,
          baseStyle: const TextStyle(fontFamily: _digitalFamily, height: 0.9),
          minFontSize: 28,
          maxFontSize: timeMaxSize,
          maxWidth: constraints.maxWidth,
          maxHeight: h - gap - dateMaxSize,
        );

        final dateSize = _fitFontSize(
          text: dateText,
          baseStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            shadows: [Shadow(color: Color(0x66000000), blurRadius: 18)],
          ),
          minFontSize: 10,
          maxFontSize: dateMaxSize,
          maxWidth: constraints.maxWidth,
          maxHeight: dateMaxSize + 6,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeText,
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: TextStyle(
                fontFamily: _digitalFamily,
                fontSize: timeSize,
                height: 0.9,
                color: const Color(0xFFE7EA44),
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 20),
                  Shadow(color: Color(0x33000000), blurRadius: 40),
                ],
              ),
            ),
            SizedBox(height: gap),
            Text(
              dateText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: dateSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 18),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

double _fitFontSize({
  required String text,
  required TextStyle baseStyle,
  required double minFontSize,
  required double maxFontSize,
  required double maxWidth,
  required double maxHeight,
}) {
  if (maxWidth <= 0 || maxHeight <= 0) return minFontSize;

  var lo = minFontSize;
  var hi = maxFontSize;
  var best = minFontSize;

  for (var i = 0; i < 10; i++) {
    final mid = (lo + hi) / 2;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(fontSize: mid),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    final fits = painter.width <= maxWidth && painter.height <= maxHeight;
    if (fits) {
      best = mid;
      lo = mid;
    } else {
      hi = mid;
    }
  }

  return best;
}

class Ticker {
  final Duration period;
  final void Function() onTick;
  bool _running = false;

  Ticker(this.period, this.onTick);

  void start() {
    if (_running) return;
    _running = true;
    _loop();
  }

  void dispose() {
    _running = false;
  }

  Future<void> _loop() async {
    while (_running) {
      await Future<void>.delayed(period);
      if (!_running) return;
      onTick();
    }
  }
}

String _formatDateIdUpper(DateTime now) {
  const days = <int, String>{
    DateTime.monday: 'SENIN',
    DateTime.tuesday: 'SELASA',
    DateTime.wednesday: 'RABU',
    DateTime.thursday: 'KAMIS',
    DateTime.friday: 'JUMAT',
    DateTime.saturday: 'SABTU',
    DateTime.sunday: 'MINGGU',
  };
  const months = <int, String>{
    1: 'JANUARI',
    2: 'FEBRUARI',
    3: 'MARET',
    4: 'APRIL',
    5: 'MEI',
    6: 'JUNI',
    7: 'JULI',
    8: 'AGUSTUS',
    9: 'SEPTEMBER',
    10: 'OKTOBER',
    11: 'NOVEMBER',
    12: 'DESEMBER',
  };

  final d = days[now.weekday] ?? '';
  final dd = now.day.toString().padLeft(2, '0');
  final m = months[now.month] ?? '';
  final yyyy = now.year.toString().padLeft(4, '0');
  return '$d, $dd $m $yyyy';
}

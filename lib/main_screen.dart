import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/config/app_config.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/agent/currency_exchange_rate_feature.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/view/currency_exchange_rate_table_view.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_feature.dart';
import 'package:qms_revamped_content_desktop_client/media/player/ui/media_player_view.dart';
import 'package:qms_revamped_content_desktop_client/product/agent/product_features.dart';
import 'package:qms_revamped_content_desktop_client/product/view/product_table_view.dart';

class MainScreen extends StatelessWidget {
  final String branchName;

  const MainScreen({super.key, this.branchName = 'KCP MEDAN MALL'});

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
          final mediaH = usableH * 0.25;
          final productH = usableH * 0.20;
          final currencyH = usableH * 0.25;
          final clockH = usableH * 0.20;

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
                        child: _Header(branchName: branchName),
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
                                nameHeader: 'PINJAMAN sd.1M',
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

class _Header extends StatelessWidget {
  final String branchName;

  const _Header({required this.branchName});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final logoH = (h * 0.58).clamp(52.0, 120.0);
        final gap = (h * 0.06).clamp(6.0, 12.0);
        final textSize = (h * 0.20).clamp(20.0, 44.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo-bri-terbaru.png', height: logoH),
              SizedBox(height: gap),
              Text(
                branchName.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: const [
                    Shadow(color: Color(0x88000000), blurRadius: 18),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
        final timeSize = (h * 0.72).clamp(52.0, 160.0);
        final gap = (h * 0.05).clamp(6.0, 14.0);
        final dateSize = (h * 0.18).clamp(14.0, 42.0);

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
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

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: content,
          ),
        );
      },
    );
  }
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

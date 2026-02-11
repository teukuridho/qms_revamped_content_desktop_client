import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/view_model/auth_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_form_view.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/event/media_download_events.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_player_controller.dart';

enum _MediaContextAction { configure, reinitialize }

class MediaPlayerView extends StatefulWidget {
  final String serviceName;
  final String tag;
  final EventManager eventManager;
  final ServerPropertiesRegistryService serverPropertiesRegistryService;
  final MediaPlayerController controller;
  final Future<void> Function()? onReinitializeRequested;

  const MediaPlayerView({
    super.key,
    required this.serviceName,
    required this.tag,
    required this.eventManager,
    required this.serverPropertiesRegistryService,
    required this.controller,
    this.onReinitializeRequested,
  });

  @override
  State<MediaPlayerView> createState() => _MediaPlayerViewState();
}

class _MediaPlayerViewState extends State<MediaPlayerView> {
  StreamSubscription<MediaDownloadStartedEvent>? _dlStartSub;
  StreamSubscription<MediaDownloadSucceededEvent>? _dlOkSub;
  StreamSubscription<MediaDownloadFailedEvent>? _dlFailSub;
  bool _reinitializeInProgress = false;

  @override
  void initState() {
    super.initState();

    widget.controller.init();

    _dlStartSub = widget.eventManager
        .listen<MediaDownloadStartedEvent>()
        .listen((e) {
          if (e.serviceName != widget.serviceName || e.tag != widget.tag) {
            return;
          }
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Downloading media...'),
              duration: Duration(days: 1),
            ),
          );
        });

    _dlOkSub = widget.eventManager.listen<MediaDownloadSucceededEvent>().listen(
      (e) {
        if (e.serviceName != widget.serviceName || e.tag != widget.tag) return;
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Media download complete (${e.downloadedCount} new)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );

    _dlFailSub = widget.eventManager.listen<MediaDownloadFailedEvent>().listen((
      e,
    ) {
      if (e.serviceName != widget.serviceName || e.tag != widget.tag) return;
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Media download failed: ${e.message}'),
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
    final content = AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final current = c.current;
        if (current == null) {
          return const Center(child: Text('No media'));
        }

        if (c.isCurrentVideo) {
          return Video(
            controller: c.videoController,
            fit: BoxFit.contain,
            fill: Colors.black,
            // controls: NoVideoControls,
          );
        }

        final p = c.currentPath;
        if (p == null || p.isEmpty) {
          return const Center(child: Text('Missing media path'));
        }

        return Image.file(
          File(p),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, st) {
            return Center(child: Text('Failed to load image: $error'));
          },
        );
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) => _showContextMenu(details.globalPosition),
      child: content,
    );
  }

  Future<void> _showContextMenu(Offset globalPosition) async {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final renderObject = overlay.context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final overlayBox = renderObject;
    final action = await showMenu<_MediaContextAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlayBox.size,
      ),
      items: [
        const PopupMenuItem<_MediaContextAction>(
          value: _MediaContextAction.configure,
          child: Text('Configure Server & Auth'),
        ),
        PopupMenuItem<_MediaContextAction>(
          value: _MediaContextAction.reinitialize,
          enabled:
              !_reinitializeInProgress &&
              widget.onReinitializeRequested != null,
          child: Text(
            _reinitializeInProgress
                ? 'Reinitializing...'
                : 'Reinitialize Media',
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _MediaContextAction.configure:
        await _openConfigurationDialog();
        break;
      case _MediaContextAction.reinitialize:
        await _reinitializeMedia();
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
                            'Media Configuration',
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
                      'Configure server connection and authentication for this media component.',
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

  Future<void> _reinitializeMedia() async {
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
          content: Text('Media reinitialized'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to reinitialize media: $e'),
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

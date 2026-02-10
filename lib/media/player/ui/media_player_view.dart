import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/event/media_download_events.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_player_controller.dart';

class MediaPlayerView extends StatefulWidget {
  final String serviceName;
  final String tag;
  final EventManager eventManager;
  final MediaPlayerController controller;

  const MediaPlayerView({
    super.key,
    required this.serviceName,
    required this.tag,
    required this.eventManager,
    required this.controller,
  });

  @override
  State<MediaPlayerView> createState() => _MediaPlayerViewState();
}

class _MediaPlayerViewState extends State<MediaPlayerView> {
  StreamSubscription<MediaDownloadStartedEvent>? _dlStartSub;
  StreamSubscription<MediaDownloadSucceededEvent>? _dlOkSub;
  StreamSubscription<MediaDownloadFailedEvent>? _dlFailSub;

  @override
  void initState() {
    super.initState();

    widget.controller.init();

    _dlStartSub = widget.eventManager
        .listen<MediaDownloadStartedEvent>()
        .listen((e) {
          if (e.serviceName != widget.serviceName || e.tag != widget.tag)
            return;
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
    return AnimatedBuilder(
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
            fit: BoxFit.cover,
            controls: (state) => const SizedBox.shrink(),
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
  }
}

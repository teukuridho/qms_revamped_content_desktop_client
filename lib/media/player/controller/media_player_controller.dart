import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide PlayerLog;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/player/event/media_play_event.dart';
import 'package:qms_revamped_content_desktop_client/media/player/event/media_playlist_ended_event.dart';
import 'package:qms_revamped_content_desktop_client/media/player/event/media_stop_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/service/media_registry_service.dart';

import 'media_reload_signal.dart';

class MediaPlayerController extends ChangeNotifier
    implements MediaReloadSignal {
  static final AppLog _log = AppLog('media_player');

  static Duration defaultImageDuration = const Duration(seconds: 5);

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final MediaRegistryService _mediaRegistryService;

  final Player _player = Player();
  late final VideoController _videoController = VideoController(_player);

  StreamSubscription<bool>? _completedSub;
  StreamSubscription<MediaPlayEvent>? _playSub;
  StreamSubscription<MediaStopEvent>? _stopSub;
  StreamSubscription<String>? _errorSub;

  Timer? _imageTimer;

  bool _disposed = false;
  bool _playing = false;

  List<MediaData> _playlist = const [];
  int _index = 0;

  bool _reloadNeeded = false;
  String? _openedVideoPath;

  MediaPlayerController({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required MediaRegistryService mediaRegistryService,
  }) : _eventManager = eventManager,
       _mediaRegistryService = mediaRegistryService {
    // Required by media_kit.
    MediaKit.ensureInitialized();
  }

  VideoController get videoController => _videoController;

  bool get playing => _playing;

  List<MediaData> get playlist => _playlist;
  int get index => _index;

  MediaData? get current =>
      (_index >= 0 && _index < _playlist.length) ? _playlist[_index] : null;

  bool get hasMedia => _playlist.isNotEmpty;

  bool get isCurrentVideo =>
      (current?.contentType ?? '').toUpperCase() == 'VIDEO';
  bool get isCurrentImage =>
      (current?.contentType ?? '').toUpperCase() == 'IMAGE';

  String? get currentPath => current?.path;

  Future<void> init() async {
    if (_disposed) throw StateError('MediaPlayerController is disposed');

    _completedSub ??= _player.stream.completed.listen((completed) {
      if (!completed) return;
      if (!_playing) return;
      if (_disposed) return;
      unawaited(_advance());
    });

    _playSub ??= _eventManager.listen<MediaPlayEvent>().listen((event) {
      if (event.serviceName != serviceName) return;
      if (event.tag != tag) return;
      unawaited(play(reason: event.reason));
    });

    _stopSub ??= _eventManager.listen<MediaStopEvent>().listen((event) {
      if (event.serviceName != serviceName) return;
      if (event.tag != tag) return;
      unawaited(stop(reason: event.reason));
    });

    _errorSub ??= _player.stream.error.listen((message) {
      _log.e('media_kit player error: $message');
    });
  }

  Future<void> loadFromDatabase() async {
    final list = await _mediaRegistryService.getAllByTagOrdered(tag: tag);
    _playlist = list;
    if (_index >= _playlist.length) {
      _index = 0;
    }
    notifyListeners();
  }

  @override
  void markReloadNeeded() {
    _reloadNeeded = true;
  }

  Future<void> play({String reason = ''}) async {
    if (_disposed) return;

    if (_playlist.isEmpty) {
      await loadFromDatabase();
    }

    if (_playlist.isEmpty) {
      _playing = false;
      notifyListeners();
      return;
    }

    _log.i('play(reason=$reason index=$_index total=${_playlist.length})');
    _playing = true;
    notifyListeners();

    // Best-effort "resume": if current is the already opened video, just play().
    final current = this.current;
    if (current != null && isCurrentVideo) {
      final path = current.path;
      final hasFrame =
          (_player.state.width ?? 0) > 0 && (_player.state.height ?? 0) > 0;
      if (_openedVideoPath == path && !_player.state.completed && hasFrame) {
        await _player.play();
        return;
      }
    }

    await _playCurrent();
  }

  Future<void> stop({String reason = ''}) async {
    if (_disposed) return;
    _log.i('stop(reason=$reason)');
    _playing = false;
    _imageTimer?.cancel();
    _imageTimer = null;
    try {
      await _player.pause();
    } catch (_) {
      // Ignore.
    }
    notifyListeners();
  }

  Future<void> goToLastAndStop() async {
    if (_playlist.isEmpty) {
      await loadFromDatabase();
    }
    if (_playlist.isNotEmpty) {
      _index = _playlist.length - 1;
    } else {
      _index = 0;
    }
    notifyListeners();
    await stop(reason: 'go_to_last');
  }

  Future<void> playFromFirst({String reason = 'play_from_first'}) async {
    if (_disposed) return;

    await loadFromDatabase();
    _index = 0;
    _openedVideoPath = null;

    if (_playlist.isEmpty) {
      _playing = false;
      notifyListeners();
      return;
    }

    _log.i('playFromFirst(reason=$reason total=${_playlist.length})');
    _playing = true;
    notifyListeners();
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    _imageTimer?.cancel();
    _imageTimer = null;

    if (!_playing || _disposed) return;

    if (_playlist.isEmpty) return;

    if (_index < 0) _index = 0;
    if (_index >= _playlist.length) {
      await _onEndOfPlaylist();
      return;
    }

    final media = _playlist[_index];
    notifyListeners();

    final path = media.path;
    final exists = await File(path).exists();
    if (!exists) {
      _log.w('Missing local media file: $path (skipping)');
      await _advance();
      return;
    }

    final contentType = media.contentType.toUpperCase();
    if (contentType == 'VIDEO') {
      _openedVideoPath = path;
      await _openVideoWithFrameFallback(path);
      return;
    }

    // Default to IMAGE.
    _imageTimer = Timer(defaultImageDuration, () {
      if (_disposed) return;
      if (!_playing) return;
      unawaited(_advance());
    });
  }

  Future<void> _advance() async {
    if (_disposed) return;
    _index += 1;
    if (_index >= _playlist.length) {
      await _onEndOfPlaylist();
      return;
    }
    await _playCurrent();
  }

  Future<void> _openVideoWithFrameFallback(String path) async {
    final loaded = await _openAndWaitForVideoFrame(path);
    if (loaded) return;

    _log.w(
      'Video frame did not become visible in time; retrying once (path=$path)',
    );

    try {
      await _player.stop();
    } catch (_) {
      // Ignore.
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final loadedAfterRetry = await _openAndWaitForVideoFrame(path);
    if (!loadedAfterRetry) {
      _log.w(
        'Unable to confirm video frame after retry; keeping playback alive (path=$path)',
      );
    }
  }

  Future<bool> _openAndWaitForVideoFrame(String path) async {
    _log.i('Opening video path=$path');
    await _player.open(Media(path), play: true);
    final hasFrame = await _waitForVideoFrame();
    if (!hasFrame) {
      _log.w(
        'No video frame detected after open (path=$path width=${_player.state.width} height=${_player.state.height})',
      );
    }
    return hasFrame;
  }

  Future<bool> _waitForVideoFrame({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final currentWidth = _player.state.width ?? 0;
    final currentHeight = _player.state.height ?? 0;
    if (currentWidth > 0 && currentHeight > 0) return true;

    try {
      await _player.stream.videoParams
          .firstWhere((p) => (p.w ?? 0) > 0 && (p.h ?? 0) > 0)
          .timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onEndOfPlaylist() async {
    _eventManager.publishEvent(
      MediaPlaylistEndedEvent(serviceName: serviceName, tag: tag),
    );

    if (_reloadNeeded) {
      _reloadNeeded = false;
      await loadFromDatabase();
    }

    // Loop.
    _index = 0;
    notifyListeners();

    if (_playing) {
      await _playCurrent();
    }
  }

  Future<void> disposeAsync() async {
    if (_disposed) return;
    _disposed = true;

    _imageTimer?.cancel();
    _imageTimer = null;

    await _completedSub?.cancel();
    _completedSub = null;

    await _playSub?.cancel();
    _playSub = null;

    await _stopSub?.cancel();
    _stopSub = null;

    await _errorSub?.cancel();
    _errorSub = null;

    try {
      await _player.dispose();
    } catch (_) {
      // Ignore.
    }
  }

  @override
  void dispose() {
    // ChangeNotifier dispose is sync; do best-effort async cleanup.
    // ignore: discarded_futures
    disposeAsync();
    super.dispose();
  }
}

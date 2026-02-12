import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/settings/service/app_settings_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: SizedBox(width: 520, height: 360, child: _SettingsDialogBody()),
    );
  }
}

class _SettingsDialogBody extends StatefulWidget {
  const _SettingsDialogBody();

  @override
  State<_SettingsDialogBody> createState() => _SettingsDialogBodyState();
}

class _SettingsDialogBodyState extends State<_SettingsDialogBody> {
  bool _loading = true;
  bool _busy = false;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = context.read<AppSettingsService>();

    bool fullscreen = false;
    if (_isDesktop) {
      try {
        fullscreen = await windowManager.isFullScreen();
      } catch (_) {
        fullscreen = await settings.getFullscreenEnabled();
      }
    } else {
      fullscreen = await settings.getFullscreenEnabled();
    }

    if (!mounted) return;
    setState(() {
      _fullscreen = fullscreen;
      _loading = false;
    });
  }

  bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  Future<void> _toggleFullscreen() async {
    if (_busy) return;

    final settings = context.read<AppSettingsService>();

    setState(() {
      _busy = true;
    });

    final next = !_fullscreen;
    try {
      if (_isDesktop) {
        await windowManager.setFullScreen(next);
      }
      await settings.setFullscreenEnabled(next);
      if (!mounted) return;
      setState(() {
        _fullscreen = next;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle fullscreen: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://teukuridho.com');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to open website')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color:
                DialogTheme.of(context).backgroundColor ??
                Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(text: 'Fullscreen'),
                Tab(text: 'About'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_buildFullscreenTab(context), _buildAboutTab(context)],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenTab(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final label = _fullscreen ? 'Exit Fullscreen' : 'Enter Fullscreen';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fullscreen', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('Current: ${_fullscreen ? 'On' : 'Off'}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy ? null : _toggleFullscreen,
            child: Text(_busy ? 'Working...' : label),
          ),
          if (!_isDesktop) ...[
            const SizedBox(height: 12),
            const Text('Note: Fullscreen toggle is only available on desktop.'),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Programmer: Teuku Ridho'),
          const SizedBox(height: 8),
          Text('WhatsApp: +6281372473096'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Website: '),
              TextButton(
                onPressed: _openWebsite,
                child: const Text('https://teukuridho.com'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

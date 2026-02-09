import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/view_model/auth_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/model/process_state.dart';
import 'package:qms_revamped_content_desktop_client/core/utility/selector.dart';

class AuthSection extends StatefulWidget {
  final AuthViewModel viewModel;

  const AuthSection({super.key, required this.viewModel});

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  late final VoidCallback _cancelBrowserSnackListener;
  late final VoidCallback _cancelQrStartSnackListener;
  late final VoidCallback _cancelQrPollSnackListener;
  late final VoidCallback _cancelLogoutSnackListener;

  @override
  void initState() {
    widget.viewModel.init();
    _attachSnackListeners();
    super.initState();
  }

  void _attachSnackListeners() {
    _cancelBrowserSnackListener = listenTo(
      widget.viewModel,
      () => widget.viewModel.loginBrowserState,
      (next) {
        if (!mounted) return;
        _showSnackForProcessState(
          next,
          success: 'Login successful',
          failurePrefix: 'Login failed',
        );
      },
    );

    _cancelQrStartSnackListener = listenTo(
      widget.viewModel,
      () => widget.viewModel.startQrState,
      (next) {
        if (!mounted) return;
        _showSnackForProcessState(
          next,
          success: 'QR login started',
          failurePrefix: 'QR login failed',
        );
      },
    );

    _cancelQrPollSnackListener = listenTo(
      widget.viewModel,
      () => widget.viewModel.pollQrState,
      (next) {
        if (!mounted) return;
        _showSnackForProcessState(
          next,
          success: 'QR login successful',
          failurePrefix: 'QR login failed',
        );
      },
    );

    _cancelLogoutSnackListener = listenTo(
      widget.viewModel,
      () => widget.viewModel.logoutState,
      (next) {
        if (!mounted) return;
        _showSnackForProcessState(
          next,
          success: 'Logged out',
          failurePrefix: 'Logout failed',
        );
      },
    );
  }

  void _showSnackForProcessState(
    ProcessState state, {
    required String success,
    required String failurePrefix,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state.state) {
      case ProcessStateEnum.success:
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(content: Text(success), backgroundColor: Colors.green),
        );
        return;
      case ProcessStateEnum.failed:
        messenger.clearSnackBars();
        final msg = state.errorMessage;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              msg == null || msg.isEmpty ? failurePrefix : '$failurePrefix: $msg',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      case ProcessStateEnum.none:
      case ProcessStateEnum.loading:
        return;
    }
  }

  @override
  void dispose() {
    _cancelBrowserSnackListener();
    _cancelQrStartSnackListener();
    _cancelQrPollSnackListener();
    _cancelLogoutSnackListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final expiresAt = vm.accessTokenExpiresAtEpochMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(vm.accessTokenExpiresAtEpochMs)
            : null;

        final da = vm.deviceAuthorization;
        final qrValue = da?.qrString ?? '';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keycloak Authentication',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.loggedIn ? 'Status: Logged in' : 'Status: Not logged in',
                ),
                if (expiresAt != null) Text('Access token expires: $expiresAt'),
                if (!vm.loggedIn)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Please connect your phone to the same network/VPN as this computer, then scan the QR to sign in.',
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: vm.loginBrowserState.state ==
                              ProcessStateEnum.loading
                          ? null
                          : vm.loginWithBrowser,
                      child: Text(
                        vm.loginBrowserState.state == ProcessStateEnum.loading
                            ? 'Waiting For Browser...'
                            : 'Login (Browser)',
                      ),
                    ),
                    if (vm.loginBrowserState.state == ProcessStateEnum.loading)
                      OutlinedButton(
                        onPressed: vm.cancelBrowserLogin,
                        child: const Text('Cancel Browser Login'),
                      ),
                    ElevatedButton(
                      onPressed: vm.startQrLogin,
                      child: const Text('Login (QR)'),
                    ),
                    ElevatedButton(
                      onPressed: (da == null ||
                              vm.pollQrState.state ==
                                  ProcessStateEnum.loading)
                          ? null
                          : vm.completeQrLogin,
                      child: Text(
                        vm.pollQrState.state == ProcessStateEnum.loading
                            ? 'Polling...'
                            : 'Complete QR (Poll)',
                      ),
                    ),
                    if (vm.pollQrState.state == ProcessStateEnum.loading)
                      OutlinedButton(
                        onPressed: vm.cancelQrPolling,
                        child: const Text('Cancel QR Polling'),
                      ),
                    OutlinedButton(
                      onPressed: vm.logout,
                      child: const Text('Logout / Clear Tokens'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (vm.loginBrowserState.errorMessage?.isNotEmpty == true)
                  Text(
                    'Browser login error: ${vm.loginBrowserState.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (vm.startQrState.errorMessage?.isNotEmpty == true)
                  Text(
                    'QR start error: ${vm.startQrState.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (vm.pollQrState.errorMessage?.isNotEmpty == true)
                  Text(
                    'QR poll error: ${vm.pollQrState.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (vm.logoutState.errorMessage?.isNotEmpty == true)
                  Text(
                    'Logout error: ${vm.logoutState.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (da != null) ...[
                  const Divider(),
                  const Text(
                    'Scan this QR with your phone to open Keycloak and approve the login.',
                  ),
                  Text('User code: ${da.userCode}'),
                  Text('Verification URL: ${da.verificationUri}'),
                  if (da.verificationUriComplete.isNotEmpty)
                    Text('Complete URL: ${da.verificationUriComplete}'),
                  Text('Expires in: ${vm.secondsLeft}s'),
                  const SizedBox(height: 8),
                  if (qrValue.isNotEmpty)
                    Center(
                      child: QrImageView(
                        data: qrValue,
                        size: 200,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

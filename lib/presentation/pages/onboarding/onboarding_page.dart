import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

/// Full-screen permission guide. Checks notification-listener access; if
/// disabled, explains the need and routes the user to system settings. After
/// returning, re-checks and navigates home once enabled.
///
/// NOTE: deliberately NOT wired into [goRouter] for MVP — the settings page
/// already covers the permission flow. Created so Phase 6 can drop it in. It
/// compiles and is reachable only if a future route is added.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool? _enabled;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final enabled =
        await ref.read(platformActionsProvider).isNotificationListenerEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _checking = false;
    });
  }

  Future<void> _openSettings() async {
    await ref.read(platformActionsProvider).openNotificationListenerSettings();
    await _check();
    if (_enabled == true && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active,
                  size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                enabled == null
                    ? '正在检查权限…'
                    : (enabled
                        ? '通知使用权已开启'
                        : '需要开启通知使用权'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '本应用需要读取来自微信等群聊的通知，按您配置的关键词筛选并提醒您。'
                '数据仅本地处理，不上传。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_checking)
                const CircularProgressIndicator()
              else if (enabled != true)
                FilledButton.icon(
                  icon: const Icon(Icons.settings_applications),
                  label: const Text('去开启'),
                  onPressed: _openSettings,
                )
              else
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('进入应用'),
                  onPressed: () => context.go('/'),
                ),
              const SizedBox(height: 16),
              if (enabled == true)
                TextButton(
                  onPressed: _check,
                  child: const Text('重新检查权限'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

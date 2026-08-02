import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/quick_reply.dart';
import '../../../domain/repositories/i_config_store.dart' show QuietHours;
import '../../providers/providers.dart';

/// App settings: notification-listener permission, quiet hours, monitored
/// target apps, monitor-service status, privacy policy, and a (stub) clear
/// action. Native platform interactions go through [platformActionsProvider]
/// (no-ops until Phase 6), so the page compiles today.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _listenerEnabled = false;
  bool _serviceRunning = false;
  bool _quietEnabled = false;
  int _startHour = 22;
  int _endHour = 7;
  List<String> _targetPackages = const [];

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _loadConfig();
  }

  Future<void> _refreshStatus() async {
    final pa = ref.read(platformActionsProvider);
    final enabled = await pa.isNotificationListenerEnabled();
    final running = await pa.isMonitorServiceRunning();
    if (mounted) {
      setState(() {
        _listenerEnabled = enabled;
        _serviceRunning = running;
      });
    }
  }

  Future<void> _loadConfig() async {
    final store = ref.read(configStoreProvider);
    final qh = (await store.getQuietHours()).fold((_) => null, (q) => q);
    final pkgs = (await store.getTargetAppPackages()).fold((_) => null, (p) => p);
    if (mounted) {
      setState(() {
        if (qh != null) {
          _quietEnabled = qh.enabled;
          _startHour = qh.startHour;
          _endHour = qh.endHour;
        }
        if (pkgs != null) _targetPackages = pkgs;
      });
    }
  }

  Future<void> _persistQuietHours() async {
    await ref.read(configStoreProvider).setQuietHours(QuietHours(
          startHour: _startHour,
          endHour: _endHour,
          enabled: _quietEnabled,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // --- 通知监听 ---
          _sectionHeader('通知监听'),
          SwitchListTile(
            title: const Text('通知使用权'),
            subtitle: Text(_listenerEnabled ? '已开启' : '未开启'),
            value: _listenerEnabled,
            // Read-only switch reflecting native state; changes happen in
            // system settings, so we just route the user there.
            onChanged: null,
          ),
          ListTile(
            leading: const Icon(Icons.settings_applications),
            title: const Text('去开启'),
            onTap: () async {
              await ref
                  .read(platformActionsProvider)
                  .openNotificationListenerSettings();
              await _refreshStatus();
            },
          ),
          const Divider(),

          // --- 监听服务状态 ---
          _sectionHeader('监听服务'),
          ListTile(
            leading: Icon(
              _serviceRunning ? Icons.check_circle : Icons.error_outline,
              color: _serviceRunning ? Colors.green : Colors.orange,
            ),
            title: const Text('服务状态'),
            subtitle: Text(_serviceRunning ? '运行中' : '已停止'),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('重启服务'),
            onTap: () async {
              await ref.read(platformActionsProvider).restartMonitorService();
              await _refreshStatus();
              if (mounted) _snack('已请求重启');
            },
          ),
          const Divider(),

          // --- 夜间静默 ---
          _sectionHeader('夜间静默'),
          SwitchListTile(
            title: const Text('启用夜间静默'),
            subtitle: const Text('静默时段内不弹出提醒'),
            value: _quietEnabled,
            onChanged: (v) {
              setState(() => _quietEnabled = v);
              _persistQuietHours();
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Text('开始'),
                const Spacer(),
                DropdownButton<int>(
                  value: _startHour,
                  items: [
                    for (var h = 0; h < 24; h++)
                      DropdownMenuItem(value: h, child: Text('$h时')),
                  ],
                  onChanged: _quietEnabled
                      ? (v) {
                          if (v == null) return;
                          setState(() => _startHour = v);
                          _persistQuietHours();
                        }
                      : null,
                ),
              ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('结束'),
                const Spacer(),
                DropdownButton<int>(
                  value: _endHour,
                  items: [
                    for (var h = 0; h < 24; h++)
                      DropdownMenuItem(value: h, child: Text('$h时')),
                  ],
                  onChanged: _quietEnabled
                      ? (v) {
                          if (v == null) return;
                          setState(() => _endHour = v);
                          _persistQuietHours();
                        }
                      : null,
                ),
              ],
            ),
          ),
          const Divider(),

          // --- 监听目标 App ---
          _sectionHeader('监听目标 App'),
          CheckboxListTile(
            title: const Text('微信'),
            subtitle: Text(_targetPackages.join(', ')),
            value: true,
            // MVP fixed target app list; not editable yet.
            onChanged: null,
          ),
          const Divider(),

          // --- 回复话术管理 ---
          _sectionHeader('回复话术管理'),
          _phraseSection(),
          const Divider(),

          // --- 其他 ---
          _sectionHeader('其他'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('隐私政策'),
            onTap: () => _showPrivacy(context),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('清空记录'),
            onTap: () => _snack('功能开发中'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('返回首页'),
            onTap: () => context.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// 回复话术管理 section: lists phrases from [quickReplyListProvider], each
  /// editable, deletable, and settable-as-default. A "+ 新建话术" button at
  /// the bottom creates a new phrase via [QuickReply.newPhrase].
  Widget _phraseSection() {
    final async = ref.watch(quickReplyListProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('加载失败：$e'),
      ),
      data: (phrases) => Column(
        children: [
          for (final p in phrases)
            ListTile(
              leading: IconButton(
                tooltip: p.isDefault ? '当前默认' : '设为默认',
                icon: Icon(
                  p.isDefault ? Icons.star : Icons.star_border,
                  color: p.isDefault
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => _setDefault(p),
              ),
              title: p.isDefault
                  ? Text(p.text, style: const TextStyle(fontWeight: FontWeight.bold))
                  : Text(p.text),
              trailing: p.isDefault
                  ? const Chip(
                      label: Text('默认'),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    )
                  : null,
              onTap: () => _showEditDialog(p),
              onLongPress: () => _confirmDelete(p),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('新建话术'),
                onPressed: () => _showNewDialog(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sets [phrase] as the default and clears the default flag on all other
  /// phrases. Each affected phrase is saved via the command runner so the
  /// list provider refreshes afterwards.
  Future<void> _setDefault(QuickReply phrase) async {
    final async = ref.read(quickReplyListProvider);
    final all = async.valueOrNull ?? const <QuickReply>[];
    final cmd = ref.read(quickReplyCommandProvider);
    for (final p in all) {
      final wantDefault = p.id == phrase.id;
      if (p.isDefault != wantDefault) {
        await cmd.save(p.copyWith(isDefault: wantDefault));
      }
    }
    if (mounted) _snack('已设为默认');
  }

  Future<void> _showNewDialog() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('新建话术'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入话术内容'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    final async = ref.read(quickReplyListProvider);
    final all = async.valueOrNull ?? const <QuickReply>[];
    final nextSort = all.isEmpty
        ? 0
        : all.map((p) => p.sortOrder).fold<int>(0, (a, b) => a > b ? a : b) + 1;
    await ref
        .read(quickReplyCommandProvider)
        .save(QuickReply.newPhrase(text: text, sortOrder: nextSort));
    if (mounted) _snack('已新建');
  }

  Future<void> _showEditDialog(QuickReply phrase) async {
    final controller = TextEditingController(text: phrase.text);
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('编辑话术'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入话术内容'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    await ref
        .read(quickReplyCommandProvider)
        .save(phrase.copyWith(text: text));
    if (mounted) _snack('已保存');
  }

  Future<void> _confirmDelete(QuickReply phrase) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('删除话术'),
        content: Text('确定删除「${phrase.text}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(quickReplyCommandProvider).delete(phrase.id);
    if (mounted) _snack('已删除');
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('隐私政策'),
        content: const Text(
          '本应用仅在本地处理您的通知内容，用于关键词匹配与提醒。'
          '匹配到的消息保存在本机数据库中，不会上传到任何服务器。'
          '您可以随时清空本地记录。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

}

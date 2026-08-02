import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/message_record.dart';
import '../../providers/providers.dart';
import '../message_detail/reply_sheet.dart';
import '../../utils/date_format.dart';
import '../../widgets/message_tile.dart';

/// Home screen: shows recently matched messages grouped by WeChat group
/// ([MessageRecord.groupId]) as collapsible sections. The most-recently-active
/// group (the group whose latest message is newest) is listed first — since
/// the underlying `messageListProvider(null)` list is already ordered
/// `occurredAt desc`, bucketing while iterating preserves that order.
///
/// Each group renders as an [ExpansionTile] (Material 3) that is EXPANDED by
/// default; the latest overall message therefore sits at the top of the first
/// section. Within a group, messages stay in `occurredAt desc` order and reuse
/// the shared [MessageTile] (compact: false) so the 回复 button, keyword
/// highlight, and tap-to-detail all keep working.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messageListProvider(null));
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息助手'),
        // 历史/设置 are now bottom-nav tabs, so only 统计 / 出行 remain here.
        actions: [
          IconButton(
            tooltip: '距离费用',
            icon: const Icon(Icons.directions_car),
            onPressed: () => context.push('/route_calc'),
          ),
          IconButton(
            tooltip: '统计',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/stats'),
          ),
        ],
      ),
      body: _body(context, messagesAsync),
    );
  }

  Widget _body(BuildContext context, AsyncValue<List<MessageRecord>> async) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('加载失败：$e'),
        ),
      ),
      data: (list) {
        if (list.isEmpty) return const _EmptyState();
        final groups = _groupByLatest(list);
        return _GroupedList(groups: groups);
      },
    );
  }
}

/// A group bucket: its stable id, display name, and the (desc-ordered) messages
/// belonging to it. The first message is the group's most recent.
class _MessageGroup {
  final String groupId;
  final String displayName;
  final List<MessageRecord> messages;

  _MessageGroup({
    required this.groupId,
    required this.displayName,
    required this.messages,
  });
}

/// Buckets [messages] by [MessageRecord.groupId], preserving the order in which
/// each group is first encountered (== most-recently-active group first, since
/// the input is `occurredAt desc`). Display name falls back to the first
/// message's senderName, then "未知群" when [MessageRecord.groupName] is null.
List<_MessageGroup> _groupByLatest(List<MessageRecord> messages) {
  final order = <String>[];
  final byId = <String, List<MessageRecord>>{};
  final displayNames = <String, String>{};
  for (final m in messages) {
    final id = m.groupId;
    if (!byId.containsKey(id)) {
      order.add(id);
      byId[id] = <MessageRecord>[];
      displayNames[id] = (m.groupName != null && m.groupName!.isNotEmpty)
          ? m.groupName!
          : (m.senderName.isNotEmpty ? m.senderName : '未知群');
    }
    byId[id]!.add(m);
  }
  return [
    for (final id in order)
      _MessageGroup(
        groupId: id,
        displayName: displayNames[id]!,
        messages: byId[id]!,
      ),
  ];
}

class _GroupedList extends StatelessWidget {
  final List<_MessageGroup> groups;
  const _GroupedList({required this.groups});

  @override
  Widget build(BuildContext context) {
    final groupCount = groups.length;
    final msgCount =
        groups.fold<int>(0, (sum, g) => sum + g.messages.length);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '共 $groupCount 个群 · $msgCount 条消息',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        for (final g in groups)
          _GroupSection(group: g),
        const SizedBox(height: 80),
      ],
    );
  }
}

/// A single collapsible group. Uses [ExpansionTile] which manages its own
/// expand/collapse state. Groups are COLLAPSED by default; the collapsed
/// header shows the latest message preview + a 回复 button (so the user can
/// reply to the newest message without expanding). Expanding reveals all the
/// group's messages (each with its own 回复 button via MessageTile).
class _GroupSection extends ConsumerWidget {
  final _MessageGroup group;
  const _GroupSection({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = group.messages.first;
    final replied = latest.isReplied;
    return ExpansionTile(
      initiallyExpanded: false,
      controlAffinity: ListTileControlAffinity.leading,
      title: Row(
        children: [
          Expanded(
            child: Text(
              group.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${formatHm(latest.occurredAt)} · ${group.messages.length}条',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Latest message preview: sender + content snippet.
          Text(
            '${latest.senderName}: ${latest.content}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          // Reply-to-latest button, visible even when collapsed.
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.reply, size: 18),
              label: const Text('回复最新'),
              style: TextButton.styleFrom(
                foregroundColor: replied ? null : Colors.green,
                visualDensity: VisualDensity.compact,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => showReplySheet(context, ref, latest),
            ),
          ),
        ],
      ),
      children: [
        for (final m in group.messages) MessageTile(message: m),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('还没有命中消息，去配置关键词吧'),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.tag),
              label: const Text('配置关键词'),
              // Keywords is a bottom-nav tab; go there (switches tab).
              onPressed: () => context.go('/keywords'),
            ),
          ],
        ),
      ),
    );
  }
}

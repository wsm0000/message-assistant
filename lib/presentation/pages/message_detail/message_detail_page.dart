import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/message_record.dart';
import '../../providers/providers.dart';
import '../../utils/date_format.dart';
import '../../widgets/keyword_highlight_text.dart';
import 'reply_sheet.dart';

/// Detail view for a single matched message. Shows full content (highlighted),
/// hit keywords + priorities, score, and actions: copy message, reply (opens
/// the quick-reply sheet), mark replied. Platform actions go through
/// [platformActionsProvider] (stub until native wiring lands).
class MessageDetailPage extends ConsumerWidget {
  final String id;
  const MessageDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(messageDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('消息详情')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (msg) {
          if (msg == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('消息不存在'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('返回'),
                  ),
                ],
              ),
            );
          }
          return _DetailBody(message: msg);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final MessageRecord message;
  const _DetailBody({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = message;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (m.groupName != null && m.groupName!.isNotEmpty)
          _meta(context, '群聊', m.groupName!),
        _meta(context, '发送人', m.senderName),
        _meta(context, '时间', formatYmdHms(m.occurredAt)),
        const SizedBox(height: 12),
        Text('内容', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: KeywordHighlightText(
            text: m.content,
            hits: m.hits,
            baseStyle: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16),
        Text('命中关键词', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        if (m.hits.isEmpty)
          const Text('（无）')
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: m.hits
                .map((h) => Chip(
                      label: Text('${h.keyword} (优先 ${h.priority})'),
                    ))
                .toList(),
          ),
        const SizedBox(height: 12),
        Text('得分: ${m.score}',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 24),
        OverflowBar(
          spacing: 8,
          overflowSpacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('复制消息'),
              onPressed: () async {
                await ref
                    .read(platformActionsProvider)
                    .copyToClipboard(m.content);
                if (!context.mounted) return;
                _snack(context, '已复制');
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.reply),
              label: const Text('回复'),
              onPressed: () => showReplySheet(context, ref, m),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.reply),
              label: const Text('标记已回复'),
              onPressed: () async {
                await ref.read(messageRepoProvider).markReplied(m.id, '');
                ref.invalidate(messageDetailProvider(m.id));
                if (!context.mounted) return;
                _snack(context, '已标记已回复');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _meta(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

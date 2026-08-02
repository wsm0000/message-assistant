import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/message_record.dart';
import '../../../domain/entities/quick_reply.dart';
import '../../providers/providers.dart';

/// Reply flow for the message detail page.
///
/// **Smart-copy**: compose `@<sender> <phrase>`, copy to clipboard, launch/jump
/// to WeChat; the user pastes+sends manually.
///
/// Entry point: [showReplySheet] — opens a modal bottom sheet listing the
/// seeded quick-reply phrases plus a "自定义…" entry.

/// Opens the quick-reply bottom sheet for [message].
///
/// Each phrase is a [ListTile]; the `isDefault` one is bolded and tagged with
/// a "默认" chip so it stands out. The bottom "自定义…" row opens a dialog
/// with a text field for a one-off custom reply. Picking any phrase (or
/// custom text) composes the reply, copies it, launches WeChat, marks the
/// message replied, invalidates the detail read-model, and shows a SnackBar.
Future<void> showReplySheet(BuildContext context, WidgetRef ref, MessageRecord message) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) => _ReplySheet(message: message),
  );
}

/// The sheet body. Watches [quickReplyListProvider] and handles its
/// AsyncValue states (loading / empty / data) defensively.
class _ReplySheet extends ConsumerWidget {
  final MessageRecord message;
  const _ReplySheet({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(quickReplyListProvider);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '选择回复话术',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const Divider(height: 8),
          Flexible(
            child: async.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('加载失败：$e')),
              ),
              data: (phrases) {
                if (phrases.isEmpty) {
                  // Defensive: seeded repo never returns empty, but guard
                  // against an unexpected state so the user can still reply.
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('暂无话术')),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in phrases) _phraseTile(context, ref, p),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 8),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('自定义…'),
            onTap: () => _promptCustom(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _phraseTile(BuildContext context, WidgetRef ref, QuickReply p) {
    return ListTile(
      leading: const Icon(Icons.reply),
      title: p.isDefault
          ? Text(p.text,
              style: const TextStyle(fontWeight: FontWeight.bold))
          : Text(p.text),
      trailing: p.isDefault
          ? const Chip(
              label: Text('默认'),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            )
          : null,
      onTap: () => _choosePhrase(context, ref, p.text),
    );
  }

  Future<void> _promptCustom(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('自定义回复'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入回复内容'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    if (!context.mounted) return;
    await _choosePhrase(context, ref, text);
  }

  Future<void> _choosePhrase(BuildContext context, WidgetRef ref, String phrase) async {
    // Compose the reply text: "@<sender> <phrase>" with a single space, then
    // smart-copy: copy to clipboard + jump/launch WeChat + mark replied.
    final composed = '@${message.senderName} $phrase';
    await _smartCopy(context, ref, composed);
  }

  /// Smart-copy fallback: copy + jump/launch + mark replied + SnackBar.
  Future<void> _smartCopy(
      BuildContext context, WidgetRef ref, String composed) async {
    final pa = ref.read(platformActionsProvider);
    await pa.copyToClipboard(composed);
    final jumped = await pa.jumpToChat(message.jumpKey);
    if (!jumped) {
      await pa.launchWechat();
    }
    await ref.read(messageRepoProvider).markReplied(message.id, composed);
    ref.invalidate(messageDetailProvider(message.id));
    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss the sheet
    _snack(context,
        jumped ? '已复制，已跳转到群聊，请粘贴发送' : '已复制，已打开微信，请粘贴发送');
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

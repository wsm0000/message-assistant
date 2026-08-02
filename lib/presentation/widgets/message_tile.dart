import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/message_record.dart';
import '../pages/message_detail/reply_sheet.dart';
import '../utils/date_format.dart';
import 'keyword_highlight_text.dart';

/// A list card for a [MessageRecord].
///
/// Used by both [HomePage] and [HistoryPage] to avoid duplication. The card
/// body (title/sender/content/highlighted keywords/命中 summary) navigates to
/// the detail page on tap. A separate small 回复 button opens the SAME
/// quick-reply sheet the detail page uses ([showReplySheet]); tapping it does
/// NOT trigger the card navigation because it is a distinct tap target inside
/// the subtitle Column.
///
/// [compact] switches the secondary line between the richer home layout
/// (separate sender + 命中 rows, time on the title row) and the history layout
/// (a single "sender · time" row). The 回复 button is present in both modes.
class MessageTile extends ConsumerWidget {
  final MessageRecord message;
  final bool compact;
  final Widget? trailing;

  const MessageTile({
    super.key,
    required this.message,
    this.compact = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = message;
    final titleText =
        m.groupName?.isNotEmpty == true ? m.groupName : m.senderName;
    // Visual reply-state cue: replied messages get a red border; unreplied get
    // the normal card surface. The reply button is green when unreplied
    // (action available), neutral when already replied.
    final replied = m.isReplied;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: replied
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.red.withValues(alpha: 0.7),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                titleText ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (!compact)
              Text(
                formatHm(m.occurredAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            if (compact)
              Text(
                '${m.senderName} · ${formatYmdHm(m.occurredAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Text(
                m.senderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            KeywordHighlightText(
              text: m.content,
              hits: m.hits,
              baseStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!compact && m.hits.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '命中: ${m.hits.map((h) => h.keyword).join(', ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            const SizedBox(height: 4),
            // Separate tap target: tapping 回复 opens the reply sheet and must
            // not propagate to the ListTile's onTap. Because this is rendered
            // inside the subtitle Column (a separate widget subtree from the
            // ListTile's inkwell gesture), tapping it does not trigger the
            // card navigation.
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('回复'),
                // Green when unreplied (action available); default when replied.
                style: TextButton.styleFrom(
                  foregroundColor: replied ? null : Colors.green,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => showReplySheet(context, ref, m),
              ),
            ),
          ],
        ),
        onTap: () => context.push('/message/${m.id}'),
      ),
    );
  }
}

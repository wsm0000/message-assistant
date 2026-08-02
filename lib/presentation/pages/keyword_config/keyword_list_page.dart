import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/keyword_rule.dart';
import '../../providers/providers.dart';

/// Lists all keyword rules grouped by [KeywordRule.groupName] (nullable). Each
/// row shows the keyword, a type chip, priority, enabled state, and
/// edit/delete actions. Empty state nudges the user to add one.
class KeywordListPage extends ConsumerWidget {
  const KeywordListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(keywordListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('关键词')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/keywords/new'),
        tooltip: '新增关键词',
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (rules) {
          if (rules.isEmpty) return const _EmptyState();
          return _GroupedList(rules: rules);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tag, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('还没有关键词，点 + 添加'),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('添加关键词'),
            onPressed: () => context.push('/keywords/new'),
          ),
        ],
      ),
    );
  }
}

class _GroupedList extends ConsumerWidget {
  final List<KeywordRule> rules;
  const _GroupedList({required this.rules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bucket rules by groupName (null bucket first, then named groups alpha).
    final byGroup = <String?, List<KeywordRule>>{};
    for (final r in rules) {
      byGroup.putIfAbsent(r.groupName, () => []).add(r);
    }
    final groupKeys = byGroup.keys.toList()
      ..sort((a, b) {
        if (a == null && b == null) return 0;
        if (a == null) return -1;
        if (b == null) return 1;
        return a.compareTo(b);
      });

    return ListView(
      children: [
        for (final key in groupKeys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              key ?? '未分组',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          for (final r in byGroup[key]!)
            _KeywordTile(rule: r, ref: ref),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _KeywordTile extends StatelessWidget {
  final KeywordRule rule;
  final WidgetRef ref;
  const _KeywordTile({required this.rule, required this.ref});

  String _typeLabel(KeywordRule r) => r.type.name == 'exact' ? '精确' : '包含';

  @override
  Widget build(BuildContext context) {
    final r = rule;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                r.keyword,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (!r.enabled)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.pause_circle_outline,
                    size: 18, color: Colors.grey),
              ),
          ],
        ),
        subtitle: Wrap(
          spacing: 8,
          children: [
            Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              label: Text(_typeLabel(r)),
            ),
            Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              label: Text('优先 ${r.priority}'),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '编辑',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/keywords/edit/${r.id}'),
            ),
            IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, r.id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('删除关键词？'),
        content: const Text('删除后不可恢复。'),
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
    if (ok == true) {
      await ref.read(keywordRepositoryCommandProvider).delete(id);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/message_tile.dart';

/// Historical matched messages with a simple client-side text search
/// (filters by content or sender). Same data source as the home page, but no
/// "configure keywords" empty-state CTA — just "暂无记录".
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(messageListProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('历史')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                hintText: '搜索内容或发送人',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
              data: (list) {
                final q = _query;
                final filtered = q.isEmpty
                    ? list
                    : list
                        .where((m) =>
                            m.content.contains(q) ||
                            m.senderName.contains(q))
                        .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('暂无记录'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (c, i) =>
                      MessageTile(message: filtered[i], compact: true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

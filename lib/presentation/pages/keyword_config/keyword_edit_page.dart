import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/keyword_rule.dart';
import '../../providers/providers.dart';

/// Create / edit a single [KeywordRule]. Per the keep-it-simple rule:
///  - excludeWords is a single comma-separated TextField, split on save.
///  - scopeGroupIds is skipped ("生效全部群"); left empty on save.
/// When [editingId] is non-null, the existing rule (from [keywordListProvider])
/// pre-fills the form on first build.
class KeywordEditPage extends ConsumerStatefulWidget {
  final String? editingId;
  const KeywordEditPage({super.key, this.editingId});

  @override
  ConsumerState<KeywordEditPage> createState() => _KeywordEditPageState();
}

class _KeywordEditPageState extends ConsumerState<KeywordEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keywordCtrl;
  late final TextEditingController _groupNameCtrl;
  late final TextEditingController _excludeCtrl;

  late MatchType _type;
  late int _priority;
  late bool _enabled;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _keywordCtrl = TextEditingController();
    _groupNameCtrl = TextEditingController();
    _excludeCtrl = TextEditingController();
    // Defer pre-fill until build so ref is available; defaults set here.
    _type = MatchType.contains;
    _priority = 50;
    _enabled = true;
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    _groupNameCtrl.dispose();
    _excludeCtrl.dispose();
    super.dispose();
  }

  void _seedFromExisting(KeywordRule r) {
    if (_initialized) return;
    _initialized = true;
    _keywordCtrl.text = r.keyword;
    _groupNameCtrl.text = r.groupName ?? '';
    _excludeCtrl.text = r.excludeWords.join(', ');
    _type = r.type;
    _priority = r.priority;
    _enabled = r.enabled;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editingId != null && !_initialized) {
      // Read current list value to pre-fill (no async jank for the common case).
      final existing = ref
          .watch(keywordListProvider)
          .whenData((list) => list
              .where((r) => r.id == widget.editingId)
              .cast<KeywordRule?>()
              .firstWhere((_) => true, orElse: () => null));
      existing.whenData((r) {
        if (r != null) _seedFromExisting(r);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingId == null ? '新增关键词' : '编辑关键词'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _keywordCtrl,
              decoration: const InputDecoration(
                labelText: '关键词 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入关键词' : null,
            ),
            const SizedBox(height: 16),
            Text('匹配方式', style: Theme.of(context).textTheme.titleSmall),
            SegmentedButton<MatchType>(
              segments: const [
                ButtonSegment(
                  value: MatchType.contains,
                  label: Text('包含'),
                ),
                ButtonSegment(
                  value: MatchType.exact,
                  label: Text('精确'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            Text('优先级: $_priority',
                style: Theme.of(context).textTheme.titleSmall),
            Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: _priority.toDouble(),
              label: '$_priority',
              onChanged: (v) => setState(() => _priority = v.round()),
            ),
            SwitchListTile(
              title: const Text('启用'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            TextFormField(
              controller: _groupNameCtrl,
              decoration: const InputDecoration(
                labelText: '分组名称（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _excludeCtrl,
              decoration: const InputDecoration(
                labelText: '排除词（逗号分隔，可选）',
                helperText: '出现这些词时不会命中',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('生效范围：全部群',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('保存'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final existing = widget.editingId == null
        ? null
        : ref.read(keywordListProvider).whenData(
            (list) => list.where((r) => r.id == widget.editingId).firstOrNull);
    final KeywordRule? base = existing?.whenData((r) => r).valueOrNull;

    final exclude = _excludeCtrl.text
        .split(',')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    final rule = KeywordRule(
      id: widget.editingId ?? const Uuid().v4(),
      keyword: _keywordCtrl.text.trim(),
      type: _type,
      priority: _priority,
      enabled: _enabled,
      groupName: _groupNameCtrl.text.trim().isEmpty
          ? null
          : _groupNameCtrl.text.trim(),
      excludeWords: exclude,
      // MVP: scope all groups. Per-group selector deferred.
      scopeGroupIds: const [],
      createdAt: base?.createdAt ?? now,
      updatedAt: now,
    );

    ref.read(keywordRepositoryCommandProvider).save(rule);
    context.pop();
  }
}

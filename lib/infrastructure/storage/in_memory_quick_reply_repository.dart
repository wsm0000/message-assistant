import 'package:dartz/dartz.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/quick_reply.dart';
import '../../domain/repositories/i_quick_reply_repository.dart';

/// MVP in-memory implementation of [IQuickReplyRepository].
/// Seeds with sensible freight-default phrases. Persistence (Drift) deferred.
class InMemoryQuickReplyRepository implements IQuickReplyRepository {
  final List<QuickReply> _phrases;

  InMemoryQuickReplyRepository({List<QuickReply>? seed})
      : _phrases = List.of(seed ?? _defaults);

  static final List<QuickReply> _defaults = [
    QuickReply(id: 'default_jiedan', text: '接单', sortOrder: 0, isDefault: true, createdAt: DateTime(2026)),
    QuickReply(id: 'default_facar', text: '已发车', sortOrder: 1, createdAt: DateTime(2026)),
    QuickReply(id: 'default_shaohou', text: '稍后联系', sortOrder: 2, createdAt: DateTime(2026)),
    QuickReply(id: 'default_yiman', text: '已满', sortOrder: 3, createdAt: DateTime(2026)),
  ];

  @override
  Future<Either<Failure, List<QuickReply>>> findAll() async {
    final sorted = [..._phrases]..sort((a, b) {
        final c = a.sortOrder.compareTo(b.sortOrder);
        return c != 0 ? c : a.createdAt.compareTo(b.createdAt);
      });
    return right(sorted);
  }

  @override
  Future<Either<Failure, QuickReply>> save(QuickReply phrase) async {
    final idx = _phrases.indexWhere((p) => p.id == phrase.id);
    final updated = phrase.copyWith(updatedAt: DateTime.now());
    if (idx >= 0) {
      _phrases[idx] = updated;
    } else {
      _phrases.add(updated);
    }
    return right(updated);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    _phrases.removeWhere((p) => p.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, void>> reorder(List<String> orderedIds) async {
    final byId = {for (var p in _phrases) p.id: p};
    for (var i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final p = byId[id];
      if (p != null) byId[id] = p.copyWith(sortOrder: i);
    }
    _phrases
      ..clear()
      ..addAll(byId.values);
    return right(null);
  }
}

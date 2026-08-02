import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/services/message_dedup_service.dart';

void main() {
  final svc = MessageDedupService();
  final base = DateTime(2026, 7, 30, 14, 32, 0);

  test('same minute same sender same content -> same fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g1','s1','南京到上海', base.add(const Duration(seconds: 30)));
    expect(f1, f2);
  });
  test('cross minute boundary -> different fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g1','s1','南京到上海', base.add(const Duration(seconds: 61)));
    expect(f1, isNot(f2));
  });
  test('different sender same content -> different fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g1','s2','南京到上海', base);
    expect(f1, isNot(f2));
  });
  test('different group -> different fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g2','s1','南京到上海', base);
    expect(f1, isNot(f2));
  });
  test('fingerprint is 40-char hex sha1', () {
    final f = svc.fingerprint('app','g1','s1','南京到上海', base);
    expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(f), isTrue);
  });
}

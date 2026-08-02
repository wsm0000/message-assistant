import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/repositories/i_config_store.dart';
import 'package:message_assistant/domain/services/notify_policy_service.dart';

void main() {
  final svc = NotifyPolicyService();

  test('disabled quiet hours always notifies', () {
    expect(svc.shouldNotify(DateTime(2026,7,30,3,0), const QuietHours.disabled()), isTrue);
  });
  test('22-07 range: 03:00 is quiet', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,3,0), qh), isFalse);
  });
  test('22-07 range: 12:00 notifies', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,12,0), qh), isTrue);
  });
  test('cross-midnight boundary: 22:00 quiet, 21:59 notify', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,22,0), qh), isFalse);
    expect(svc.shouldNotify(DateTime(2026,7,30,21,59), qh), isTrue);
  });
  test('07:00 notify, 06:59 quiet', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,7,0), qh), isTrue);
    expect(svc.shouldNotify(DateTime(2026,7,30,6,59), qh), isFalse);
  });
  // Non-crossing window (e.g. 9-17 daytime quiet)
  test('non-crossing window 09-17: 12:00 quiet, 08:59 notify', () {
    const qh = QuietHours(startHour: 9, endHour: 17, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,12,0), qh), isFalse);
    expect(svc.shouldNotify(DateTime(2026,7,30,8,59), qh), isTrue);
    expect(svc.shouldNotify(DateTime(2026,7,30,17,0), qh), isTrue);
    expect(svc.shouldNotify(DateTime(2026,7,30,16,59), qh), isFalse);
  });
  test('start==end treated as no-op (always notify)', () {
    const qh = QuietHours(startHour: 5, endHour: 5, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,5,0), qh), isTrue);
    expect(svc.shouldNotify(DateTime(2026,7,30,12,0), qh), isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/failure.dart';

void main() {
  test('DatabaseFailure carries message', () {
    const f = DatabaseFailure('boom');
    expect(f.message, 'boom');
  });
  test('Failure equality by type+message', () {
    expect(const DatabaseFailure('x'), const DatabaseFailure('x'));
    expect(const DatabaseFailure('x') == const ParseFailure('x'), isFalse);
  });
}

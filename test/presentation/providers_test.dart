import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/infrastructure/database/database.dart';
import 'package:message_assistant/presentation/providers/providers.dart';

/// Proves the provider -> repository -> Drift wiring is functional end-to-end.
/// Both tests override [databaseProvider] with an in-memory Drift database so
/// no on-disk state is touched.
void main() {
  test('messageListProvider returns empty list via wired repo', () async {
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
    ]);
    addTearDown(container.dispose);

    final list = await container.read(messageListProvider(null).future);
    expect(list, isEmpty);
  });

  test('keywordListProvider returns empty list initially', () async {
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
    ]);
    addTearDown(container.dispose);

    final list = await container.read(keywordListProvider.future);
    expect(list, isEmpty);
  });
}

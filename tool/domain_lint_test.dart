// Tests for the domain-layer import isolation lint.
//
// The lint's whitelist logic lives in the exported `isAllowed` function in
// `tool/domain_lint.dart`; these tests pin its behavior so later tasks can
// rely on it.
//
// Note: we import the `test`/`expect` API via `package:flutter_test` because
// the standalone `package:test` cannot be added on this SDK (it conflicts
// with `flutter_test`'s pinned `matcher` version). The API surface used here
// is identical.
//
// Run with:  flutter test tool/domain_lint_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'domain_lint.dart';

void main() {
  group('isAllowed', () {
    test('allows dart: core URIs', () {
      expect(isAllowed('dart:core'), isTrue);
      expect(isAllowed('dart:async'), isTrue);
      expect(isAllowed('dart:io'), isTrue);
    });

    test('allows whitelisted package: URIs (prefix match)', () {
      expect(isAllowed('package:dartz/dartz.dart'), isTrue);
      expect(isAllowed('package:equatable/equatable.dart'), isTrue);
      expect(isAllowed('package:meta/meta.dart'), isTrue);
      expect(isAllowed('package:freezed_annotation/freezed_annotation.dart'),
          isTrue);
      expect(isAllowed('package:json_annotation/json_annotation.dart'), isTrue);
      expect(isAllowed('package:uuid/uuid.dart'), isTrue);
      expect(isAllowed('package:crypto/crypto.dart'), isTrue);
    });

    test('forbids package:flutter/...', () {
      expect(isAllowed('package:flutter/material.dart'), isFalse);
      expect(isAllowed('package:flutter/widgets.dart'), isFalse);
      expect(isAllowed('package:flutter_riverpod/flutter_riverpod.dart'),
          isFalse);
    });

    test('forbids package:riverpod/...', () {
      expect(isAllowed('package:riverpod/riverpod.dart'), isFalse);
    });

    test('forbids other external packages not on the whitelist', () {
      expect(isAllowed('package:go_router/go_router.dart'), isFalse);
      expect(isAllowed('package:drift/drift.dart'), isFalse);
      expect(isAllowed('package:path_provider/path_provider.dart'), isFalse);
    });

    test('allows same-package relative imports', () {
      expect(isAllowed('../entities/foo.dart'), isTrue);
      expect(isAllowed('./foo.dart'), isTrue);
      expect(isAllowed('foo.dart'), isTrue);
      expect(isAllowed('entities/bar.dart'), isTrue);
      expect(isAllowed('../../core/error.dart'), isTrue);
    });
  });

  group('findViolations', () {
    test('returns empty for a non-existent directory', () {
      final violations = findViolations(Directory('does/not/exist'));
      expect(violations, isEmpty);
    });
  });
}

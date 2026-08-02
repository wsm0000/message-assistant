// Lint script: enforce that lib/domain/** never imports Flutter or other
// disallowed packages. The domain layer must stay pure Dart so it can be
// unit-tested without a device.
//
// Run with:  dart run tool/domain_lint.dart
// Exit code 0 = all imports OK, 1 = a disallowed import was found.

import 'dart:io';

/// Whitelist of allowed `package:` URI prefixes for the domain layer.
const List<String> _allowedPackagePrefixes = <String>[
  'package:dartz/',
  'package:equatable/',
  'package:meta/',
  'package:freezed_annotation/',
  'package:json_annotation/',
  'package:uuid/',
  'package:crypto/',
];

/// Returns true if [importUri] is an allowed import inside `lib/domain/`.
///
/// Rules (prefix match for `package:` URIs, exact prefix for `dart:` URIs):
///   * `dart:` core/async/etc. -> always allowed
///   * whitelisted `package:` URIs (see [_allowedPackagePrefixes]) -> allowed
///   * relative imports (`./`, `../`, or a bare same-package relative path
///     like `foo.dart` / `src/...`) -> allowed
///   * everything else (e.g. `package:flutter/...`, `package:riverpod/...`)
///     -> NOT allowed
bool isAllowed(String importUri) {
  final String uri = importUri.trim();

  // dart: URIs are always fine (dart:core, dart:async, dart:io, ...).
  if (uri.startsWith('dart:')) {
    return true;
  }

  // Whitelisted package: URIs (prefix match).
  if (uri.startsWith('package:')) {
    for (final String prefix in _allowedPackagePrefixes) {
      if (uri.startsWith(prefix)) {
        return true;
      }
    }
    // Any other package: import is forbidden in the domain layer.
    return false;
  }

  // Relative imports are allowed within the domain layer.
  // - explicit relative: starts with `./` or `../`
  // - bare same-package relative: no scheme (`:`), e.g. `foo.dart`,
  //   `entities/bar.dart`, `../entities/foo.dart` (covered above).
  if (uri.startsWith('./') || uri.startsWith('../')) {
    return true;
  }
  if (!uri.contains(':')) {
    // No scheme => a same-package relative path. Allow it.
    return true;
  }

  // Anything else (unknown scheme) is not allowed.
  return false;
}

/// Extracts the URI string from a single `import`/`export`/`part` directive
/// line, or returns null if the line is not such a directive.
String? _extractDirectiveUri(String line) {
  final String trimmed = line.trim();
  if (!trimmed.startsWith('import ') &&
      !trimmed.startsWith('export ') &&
      !trimmed.startsWith('part ')) {
    return null;
  }
  // Find the quoted string: either ' or ".
  final int single = trimmed.indexOf("'");
  final int dbl = trimmed.indexOf('"');
  int quoteStart;
  String quoteChar;
  if (single >= 0 && (dbl < 0 || single < dbl)) {
    quoteStart = single;
    quoteChar = "'";
  } else if (dbl >= 0) {
    quoteStart = dbl;
    quoteChar = '"';
  } else {
    return null;
  }
  final int quoteEnd = trimmed.indexOf(quoteChar, quoteStart + 1);
  if (quoteEnd <= quoteStart) {
    return null;
  }
  return trimmed.substring(quoteStart + 1, quoteEnd);
}

Iterable<String> _dartFilesUnder(Directory dir) sync* {
  if (!dir.existsSync()) return;
  for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity.path;
    }
  }
}

bool _isGenerated(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

/// Scans [domainDir] for `.dart` files and returns the list of violations,
/// each as a string of the form "$file: disallowed import: $uri".
///
/// Returns an empty list if everything is clean. A null/missing directory is
/// treated as clean (no files to check).
List<String> findViolations(Directory domainDir) {
  final List<String> violations = <String>[];
  if (!domainDir.existsSync()) {
    return violations;
  }
  for (final String path in _dartFilesUnder(domainDir)) {
    if (_isGenerated(path)) continue;
    final List<String> lines = File(path).readAsLinesSync();
    for (final String line in lines) {
      final String? uri = _extractDirectiveUri(line);
      if (uri == null) continue;
      if (!isAllowed(uri)) {
        violations.add('$path: disallowed import: $uri');
      }
    }
  }
  return violations;
}

void main(List<String> args) {
  final Directory domainDir =
      Directory('${Directory.current.path}/lib/domain');

  if (!domainDir.existsSync()) {
    stderr.writeln('domain_lint: lib/domain not found at ${domainDir.path}');
    // Treat a missing domain dir as vacuously clean so the project still
    // analyzes before any domain code exists.
    stdout.writeln('domain layer imports OK');
    exit(0);
  }

  final List<String> violations = findViolations(domainDir);
  if (violations.isEmpty) {
    stdout.writeln('domain layer imports OK');
    exit(0);
  } else {
    stderr.writeln('domain_lint: found ${violations.length} disallowed '
        'import(s) in lib/domain:');
    for (final String v in violations) {
      stderr.writeln('  - $v');
    }
    exit(1);
  }
}

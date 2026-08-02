import 'package:flutter/material.dart';

/// Tiny manual date/time formatters. `intl` is intentionally not a dependency
/// (see pubspec), so these helpers format a [DateTime] without locale machinery.
/// Enough for an MVP Chinese UI: "HH:mm", "HH:mm:ss", and "yyyy-MM-dd HH:mm".

String _two(int n) => n.toString().padLeft(2, '0');

/// Formats a [DateTime] as `HH:mm`, e.g. "09:05".
String formatHm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

/// Formats a [DateTime] as `HH:mm:ss`, e.g. "09:05:03".
String formatHms(DateTime t) =>
    '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

/// Formats a [DateTime] as `yyyy-MM-dd HH:mm`, e.g. "2026-07-30 09:05".
String formatYmdHm(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

/// Formats a [DateTime] as `yyyy-MM-dd HH:mm:ss`.
String formatYmdHms(DateTime t) =>
    '${formatYmdHm(t)}:${_two(t.second)}';

/// Returns a one-off [MaterialLocalizations] is overkill here; this helper just
/// joins the time helpers for convenience. Kept for parity/readability.
extension DateTimeFormat on DateTime {
  String get hm => formatHm(this);
  String get ymdHm => formatYmdHm(this);
  String get ymdHms => formatYmdHms(this);
}

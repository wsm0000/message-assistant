import '../repositories/i_config_store.dart';

/// Decides whether a matched message should fire a local notification,
/// based on the user's quiet-hours configuration.
///
/// Behaviour: during quiet hours, matched messages are STILL persisted (not
/// lost), but no local notification is sent. Quiet hours is a time window;
/// it may cross midnight (e.g. 22:00->07:00).
class NotifyPolicyService {
  /// Returns true if a notification should be shown at [now] given [qh].
  bool shouldNotify(DateTime now, QuietHours qh) {
    if (!qh.enabled) return true;
    if (qh.startHour == qh.endHour) return true; // invalid/no-op config
    final hour = now.hour;
    final inQuiet = qh.startHour < qh.endHour
        ? (hour >= qh.startHour && hour < qh.endHour) // same-day window e.g. 9-17
        : (hour >= qh.startHour || hour < qh.endHour); // cross-midnight e.g. 22-7
    return !inQuiet;
  }
}

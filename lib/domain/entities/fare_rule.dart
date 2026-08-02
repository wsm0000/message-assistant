import 'package:equatable/equatable.dart';

/// Pricing rule for one ride-hailing fare class. Pure value object + a pure
/// `estimate` function — no external packages (kept domain-clean).
///
/// The estimate follows the common ride-hailing model:
///   - a flat **start fare** ([startFare]) covers up to [startDistanceKm];
///   - beyond that, a per-km **distance fee** ([perKmFee]);
///   - plus a per-minute **duration fee** ([perMinuteFee]) for the whole trip.
class FareRule extends Equatable {
  /// Display label, e.g. "经济型" / "舒适型".
  final String className;
  final double startFare;
  final double startDistanceKm;
  final double perKmFee;
  final double perMinuteFee;

  const FareRule({
    required this.className,
    required this.startFare,
    required this.startDistanceKm,
    required this.perKmFee,
    required this.perMinuteFee,
  });

  /// Estimate the total fare (CNY) for a trip of the given distance + duration.
  /// Rounded to the nearest yuan, like the ride-hailing apps do.
  double estimate({required int distanceMeters, required int durationSeconds}) {
    final km = distanceMeters / 1000.0;
    final minutes = durationSeconds / 60.0;
    var total = startFare;
    final extraKm = km - startDistanceKm;
    if (extraKm > 0) total += extraKm * perKmFee;
    total += minutes * perMinuteFee;
    // Round to nearest yuan.
    return (total).roundToDouble();
  }

  @override
  List<Object?> get props =>
      [className, startFare, startDistanceKm, perKmFee, perMinuteFee];
}

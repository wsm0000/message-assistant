import '../../domain/entities/fare_rule.dart';

/// Default ride-hailing fare rules used for estimates. Loosely modeled on
/// common Chinese ride-hailing pricing (经济型 / 舒适型); adjust per city.
///
/// These are heuristics, not authoritative fares — the UI labels the result as
/// an estimate.
const List<FareRule> defaultFareRules = [
  FareRule(
    className: '经济型',
    startFare: 13,
    startDistanceKm: 3,
    perKmFee: 2.3,
    perMinuteFee: 0.5,
  ),
  FareRule(
    className: '舒适型',
    startFare: 18,
    startDistanceKm: 3,
    perKmFee: 3.0,
    perMinuteFee: 0.7,
  ),
];

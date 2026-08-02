import 'package:equatable/equatable.dart';

/// A geographic point: latitude + longitude + the human-readable address it
/// was resolved from. Plain value object — no map-SDK types leak in here.
class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;
  final String address;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

/// The result of a route distance/fee calculation between two addresses.
///
/// `distanceMeters` / `durationSeconds` come from the routing service; the
/// `fares` list is the fee estimate for each fare class (economic / comfort /
/// etc.) computed locally from [FareRule]s.
class RouteEstimate extends Equatable {
  final GeoPoint origin;
  final GeoPoint destination;
  final int distanceMeters;
  final int durationSeconds;
  final List<RouteFare> fares;

  const RouteEstimate({
    required this.origin,
    required this.destination,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.fares,
  });

  @override
  List<Object?> get props => [
        origin,
        destination,
        distanceMeters,
        durationSeconds,
        fares,
      ];
}

/// One fare-class estimate within a [RouteEstimate].
class RouteFare extends Equatable {
  /// Display label, e.g. "经济型" / "舒适型".
  final String className;
  /// Estimated total fare in CNY (yuan).
  final double amountCny;

  const RouteFare({
    required this.className,
    required this.amountCny,
  });

  @override
  List<Object?> get props => [className, amountCny];
}

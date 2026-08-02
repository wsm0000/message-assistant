import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../entities/route_estimate.dart';

/// Port (hexagonal architecture) for a route distance/fee service.
///
/// Implementations live in the infrastructure layer (e.g. the Amap REST
/// adapter). The interface deliberately takes plain address strings and
/// returns domain [RouteEstimate]s — no map-SDK types leak across the port.
abstract class IRouteGateway {
  /// Geocode both addresses, then compute the driving distance + duration
  /// between them, and estimate per-class fares.
  ///
  /// Returns [Left] with a [Failure] (network error, address not found, etc.)
  /// or [Right] with the estimate.
  Future<Either<Failure, RouteEstimate>> calculateDistance({
    required String originAddress,
    required String destinationAddress,
  });
}

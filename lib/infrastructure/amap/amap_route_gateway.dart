import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/failure.dart';
import '../../domain/entities/fare_rule.dart';
import '../../domain/entities/route_estimate.dart';
import '../../domain/repositories/i_route_gateway.dart';
import 'fare_rules.dart';

/// Amap (高德) REST adapter for [IRouteGateway]. Uses the Web Service API:
///   - geocoding:  `GET /v3/geocode/geo`  (address → lng,lat)
///   - distance:   `GET /v3/distance`     (origins,destination lng,lat → m, s)
///
/// All HTTP/SDK concerns (dio, JSON parsing, error mapping) live HERE — the
/// domain port stays pure. Errors map to [NetworkFailure] / [GatewayFailure].
class AmapRouteGateway implements IRouteGateway {
  AmapRouteGateway({
    required String apiKey,
    required List<FareRule> fareRules,
    Dio? dio,
  })  : _apiKey = apiKey,
        _fareRules = fareRules,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ));

  final String _apiKey;
  final List<FareRule> _fareRules;
  final Dio _dio;

  static const _base = 'https://restapi.amap.com';

  @override
  Future<Either<Failure, RouteEstimate>> calculateDistance({
    required String originAddress,
    required String destinationAddress,
  }) async {
    if (_apiKey == 'YOUR_AMAP_KEY' || _apiKey.isEmpty) {
      return const Left(GatewayFailure('未配置高德 API Key，请在代码中填入有效 Key。'));
    }
    try {
      // 1) Geocode both addresses to lng,lat.
      final origin = await _geocode(originAddress);
      if (origin == null) {
        return Left(GatewayFailure('无法解析起点地址「$originAddress」'));
      }
      final destination = await _geocode(destinationAddress);
      if (destination == null) {
        return Left(GatewayFailure('无法解析终点地址「$destinationAddress」'));
      }

      // 2) Measure driving distance + duration.
      final dist = await _distance(origin.lngLat, destination.lngLat);
      if (dist == null) {
        return const Left(GatewayFailure('距离测量失败，请稍后重试。'));
      }
      final (distanceMeters, durationSeconds) = dist;

      // 3) Estimate fares per rule.
      final fares = _fareRules
          .map((r) => RouteFare(
                className: r.className,
                amountCny: r.estimate(
                  distanceMeters: distanceMeters,
                  durationSeconds: durationSeconds,
                ),
              ))
          .toList();

      return Right(RouteEstimate(
        origin: GeoPoint(
          latitude: origin.latitude,
          longitude: origin.longitude,
          address: originAddress,
        ),
        destination: GeoPoint(
          latitude: destination.latitude,
          longitude: destination.longitude,
          address: destinationAddress,
        ),
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        fares: fares,
      ));
    } on DioException catch (e) {
      return Left(NetworkFailure('网络请求失败：${e.message}'));
    } catch (e) {
      return Left(GatewayFailure('计算失败：$e'));
    }
  }

  /// Geocode an address → (longitude, latitude). Returns null when the API
  /// returns no result. Amap's `location` is "lng,lat" (lng first).
  Future<_Coord?> _geocode(String address) async {
    final res = await _dio.get('$_base/v3/geocode/geo', queryParameters: {
      'key': _apiKey,
      'address': address,
    });
    final data = res.data as Map<dynamic, dynamic>;
    if (data['status'] != '1') return null;
    final geocodes = data['geocodes'] as List?;
    if (geocodes == null || geocodes.isEmpty) return null;
    final location = geocodes.first['location'] as String?;
    if (location == null || !location.contains(',')) return null;
    final parts = location.split(',');
    final lng = double.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    if (lng == null || lat == null) return null;
    return _Coord(lng, lat);
  }

  /// Measure driving distance (meters) + duration (seconds) between two
  /// "lng,lat" strings. Amap distance type=1 is driving.
  Future<(int, int)?> _distance(String originsLngLat, String destLngLat) async {
    final res = await _dio.get('$_base/v3/distance', queryParameters: {
      'key': _apiKey,
      'origins': originsLngLat,
      'destination': destLngLat,
      'type': '1', // 1 = driving
    });
    final data = res.data as Map<dynamic, dynamic>;
    if (data['status'] != '1') return null;
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return null;
    final r = results.first as Map<dynamic, dynamic>;
    final distance = int.tryParse('${r['distance']}');
    final duration = int.tryParse('${r['duration']}');
    if (distance == null || duration == null) return null;
    return (distance, duration);
  }
}

/// Internal lng/lat holder (lng first, matching Amap's convention).
class _Coord {
  final double longitude;
  final double latitude;
  const _Coord(this.longitude, this.latitude);
  String get lngLat => '$longitude,$latitude';
}

/// Provider-friendly factory with sensible defaults.
AmapRouteGateway amapRouteGatewayFactory({String? apiKey, Dio? dio}) =>
    AmapRouteGateway(
      apiKey: apiKey ?? amapApiKey,
      fareRules: defaultFareRules,
      dio: dio,
    );

/// The Amap Web Service API key. Replace the placeholder with your own key
/// from https://lbs.amap.com (创建"Web服务"类型的应用). Do NOT commit a real
/// key to version control.
const String amapApiKey = 'YOUR_AMAP_KEY';

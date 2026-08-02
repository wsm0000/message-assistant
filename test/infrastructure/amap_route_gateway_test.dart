import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/entities/route_estimate.dart';
import 'package:message_assistant/domain/entities/fare_rule.dart';
import 'package:message_assistant/infrastructure/amap/amap_route_gateway.dart';

/// A fake [Dio] that returns canned JSON per-URL, for deterministic tests.
class _FakeDio implements Dio {
  /// Maps a URL substring → the JSON body to return for any GET hitting it.
  /// Later entries for the same substring override earlier ones (LIFO), so a
  /// test can stage multiple responses in call order.
  final List<MapEntry<String, Map<String, dynamic>>> staged = [];

  void stage(String urlSub, Map<String, dynamic> body) {
    staged.add(MapEntry(urlSub, body));
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Pop the first staged entry whose URL substring matches.
    for (var i = 0; i < staged.length; i++) {
      if (path.contains(staged[i].key)) {
        final body = staged.removeAt(i).value;
        return Response<T>(
          data: body as T,
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        );
      }
    }
    throw DioException(
      requestOptions: RequestOptions(path: path),
      message: 'no staged response for $path',
    );
  }

  // Below: no-op stubs for the rest of the Dio interface (only get is used).
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDio dio;

  setUp(() {
    dio = _FakeDio();
  });

  AmapRouteGateway makeGateway({String key = 'test-key'}) => AmapRouteGateway(
        apiKey: key,
        fareRules: const [
          FareRule(
              className: '经济型',
              startFare: 13,
              startDistanceKm: 3,
              perKmFee: 2.3,
              perMinuteFee: 0.5),
        ],
        dio: dio,
      );

  test('returns GatewayFailure when the API key is the placeholder', () async {
    final gw = AmapRouteGateway(
      apiKey: 'YOUR_AMAP_KEY',
      fareRules: const [],
      dio: dio,
    );
    final res = await gw.calculateDistance(
      originAddress: '北京西站',
      destinationAddress: '首都机场',
    );
    expect(res.isLeft(), isTrue);
    expect(res.fold((l) => l, (_) => throw StateError('expected left')), isA<GatewayFailure>());
  });

  test('returns Left when geocoding the origin yields no result', () async {
    dio.stage('/v3/geocode/geo', {'status': '0', 'geocodes': []});
    final gw = makeGateway();
    final res = await gw.calculateDistance(
      originAddress: '不存在的地方',
      destinationAddress: '首都机场',
    );
    expect(res.isLeft(), isTrue);
    expect(
      res.fold((l) => l, (_) => throw StateError('expected left')).message,
      contains('无法解析起点地址'),
    );
  });

  test('returns a RouteEstimate on a successful geocode + distance', () async {
    // Two geocode calls + one distance call. The fake pops per matching URL,
    // and we stage two identical geocode bodies so both pops succeed.
    dio.stage('/v3/geocode/geo', {
      'status': '1',
      'geocodes': [
        {'location': '116.322,39.900'},
      ],
    });
    dio.stage('/v3/geocode/geo', {
      'status': '1',
      'geocodes': [
        {'location': '116.611,40.080'},
      ],
    });
    dio.stage('/v3/distance', {
      'status': '1',
      'results': [
        {'distance': '35000', 'duration': '2400'},
      ],
    });
    final gw = makeGateway();
    final res = await gw.calculateDistance(
      originAddress: '北京西站',
      destinationAddress: '首都机场',
    );
    expect(res.isRight(), isTrue);
    final est = res.fold((_) => throw StateError('expected right'), (r) => r);
    expect(est, isA<RouteEstimate>());
    expect(est.distanceMeters, 35000);
    expect(est.durationSeconds, 2400);
    expect(est.origin.longitude, 116.322);
    expect(est.origin.latitude, 39.900);
    expect(est.fares, hasLength(1));
    expect(est.fares.single.className, '经济型');
  });

  test('fare estimate follows the start + per-km + per-minute model', () {
    const rule = FareRule(
      className: '经济型',
      startFare: 13,
      startDistanceKm: 3,
      perKmFee: 2.3,
      perMinuteFee: 0.5,
    );
    // 35km, 40min: 13 + (35-3)*2.3 + 40*0.5 = 13 + 73.6 + 20 = 106.6 → 107.
    expect(rule.estimate(distanceMeters: 35000, durationSeconds: 2400), 107);
    // Short trip within start distance: 13 + 0 + (10min*0.5)=5 → 18.
    expect(rule.estimate(distanceMeters: 2000, durationSeconds: 600), 18);
  });
}

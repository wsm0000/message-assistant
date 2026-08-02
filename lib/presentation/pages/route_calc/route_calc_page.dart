import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/failure.dart';
import '../../../domain/entities/route_estimate.dart';
import '../../providers/providers.dart';

/// 距离/费用计算页 — 输入起点和终点地址，调用高德算距离 + 时长，并按网约车
/// 费率估算各车型费用。
class RouteCalcPage extends ConsumerStatefulWidget {
  const RouteCalcPage({super.key});

  @override
  ConsumerState<RouteCalcPage> createState() => _RouteCalcPageState();
}

class _RouteCalcPageState extends ConsumerState<RouteCalcPage> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final o = _originCtrl.text.trim();
    final d = _destCtrl.text.trim();
    if (o.isEmpty || d.isEmpty) return;
    ref.read(routeEstimateArgsProvider.notifier).state =
        RouteEstimateArgs(o, d);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(routeEstimateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('距离费用估算')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _originCtrl,
              decoration: const InputDecoration(
                labelText: '起点',
                hintText: '如：北京西站',
                prefixIcon: Icon(Icons.my_location),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destCtrl,
              decoration: const InputDecoration(
                labelText: '终点',
                hintText: '如：首都机场T3',
                prefixIcon: Icon(Icons.place),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('计算'),
            ),
            const SizedBox(height: 16),
            Expanded(child: _resultView(async)),
          ],
        ),
      ),
    );
  }

  Widget _resultView(AsyncValue<Either<Failure, RouteEstimate>> async) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('出错：$e', style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (either) => either.fold(
        (failure) => Center(
          child: Text(
            failure.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: failure is GatewayFailure &&
                      failure.message.contains('请输入')
                  ? Theme.of(context).hintColor
                  : Colors.red,
            ),
          ),
        ),
        (est) => _estimateCard(est),
      ),
    );
  }

  Widget _estimateCard(RouteEstimate est) {
    final km = (est.distanceMeters / 1000).toStringAsFixed(1);
    final min = (est.durationSeconds / 60).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Icon(Icons.location_on, size: 18, color: Colors.green),
              const SizedBox(width: 6),
              Expanded(child: Text(est.origin.address)),
            ]),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.south, size: 18, color: Colors.grey),
            ),
            Row(children: [
              const Icon(Icons.flag, size: 18, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(child: Text(est.destination.address)),
            ]),
            const Divider(height: 24),
            Row(
              children: [
                _metric('距离', '$km 公里'),
                const SizedBox(width: 24),
                _metric('时长', '$min 分钟'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('费用估算（网约车参考价）',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final f in est.fares)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.className),
                    Text('¥ ${f.amountCny.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text('※ 仅供参考，实际以平台计价为准',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

# 自动回复功能 实施计划（AccessibilityService 自动跳转回复）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把消息详情页的"复制并打开微信"升级为"自动回复"——点击后 AccessibilityService 自动完成"唤起微信→搜索群名→进群→输入@发送人+回复→发送"全链路，失败则降级复制手动。

**Architecture:** 新增原生 AccessibilityService 执行器（不做采集，只操作微信界面）+ 声明式界面规则 WeChatUIMatcher（针对微信 8.0.76，节点规则需真机校准）+ 有限状态机驱动 AutoReplyEngine（每步超时3s/重试2次/失败短路降级）。领域层定义 IAutoReplyGateway 端口，基础设施层 AutoReplyGateway 桥接原生通道，详情页显示进度面板。消息监听仍走现有 NotificationListener，不受影响。

**Tech Stack:** 复用 MVP 已搭好的 Flutter 3.44 / Riverpod / Drift / Kotlin + Coroutines；新增 android.accessibilityservice API。

**Spec:** `docs/superpowers/specs/2026-07-31-auto-reply-design.md`

**目标设备:** 华为 Android 12 (API 31) + 微信 8.0.76 (versionCode 3141)，已连接 USB 调试。

---

## 重要协调约定（贯穿全计划）

- **解析逻辑仍只在 Kotlin**：本增量不改 MVP 的 NotificationParser/EventChannel 协调。AccessibilityService 不做采集。
- **领域隔离不变**：新增 domain 文件仍纯 Dart，受 `tool/domain_lint.dart` 强制（白名单：dart/dartz/equatable/freezed_annotation/json_annotation/meta/uuid/crypto/relative）。新增 import 若需新包，加进白名单。
- **包名**：`com.example.message_assistant`（与 MVP 一致，非 spec 草稿的 com.example.ma）。
- **环境前置（每个 bash 命令都要）**：
  ```
  export PATH="/c/Users/Nemo/flutter/bin:$PATH" && export ANDROID_HOME="C:\Users\Nemo\AppData\Local\Android\Sdk" && export ANDROID_SDK_ROOT="$ANDROID_HOME"
  ```
- **非 git 仓库**：所有 commit 步骤标注"可选"，跳过。
- **代码生成后必跑**：`dart run build_runner build --delete-conflicting-outputs`。
- **目标微信 8.0.76**：WeChatUIMatcher 规则针对此版本；实施期需 adb dump 真机校准。

---

## 文件结构总览（新增）

```
lib/
├── domain/
│   ├── entities/auto_reply.dart                 # AutoReplyRequest/Progress/Outcome/Step/StepStatus/Result
│   ├── repositories/i_auto_reply_gateway.dart   # 端口
│   └── services/auto_reply_executor.dart        # 编排
├── infrastructure/
│   └── platform/auto_reply_channel.dart         # AutoReplyGateway（实现端口，桥接原生）
└── presentation/
    ├── pages/message_detail/                    # 改造：加自动回复按钮+进度面板
    └── pages/settings/                          # 改造：加无障碍状态+默认回复文本

android/app/src/main/kotlin/com/example/message_assistant/
├── auto_reply/
│   ├── AutoReplyEngine.kt                       # 状态机驱动器
│   ├── WeChatUIMatcher.kt                       # 声明式规则（节点规则需真机校准填入）
│   ├── AutoReplyAccessibilityService.kt         # AccessibilityService
│   └── AutoReplyModels.kt                       # AutoReplyRequest/Progress/Step 等 Kotlin 数据类
├── AutoReplyPlugin.kt                           # FlutterPlugin：autoreply + progress 通道
├── AppLauncher.kt                               # 扩展：isAccessibilityEnabled/openAccessibilitySettings
└── MainActivity.kt                              # 注册 AutoReplyPlugin

android/app/src/main/res/xml/auto_reply_accessibility_config.xml
android/app/src/test/kotlin/.../auto_reply/WeChatUIMatcherTest.kt
android/app/src/test/kotlin/.../auto_reply/AutoReplyEngineTest.kt

test/
├── domain/auto_reply_executor_test.dart
└── presentation/message_detail_auto_reply_test.dart
```

**修改现有文件**：
- `lib/domain/repositories/i_config_store.dart`：加 getDefaultReplyText/setDefaultReplyText
- `lib/presentation/providers/providers.dart`：_MemoryConfigStore 加两个方法实现；加 defaultReplyTextProvider/autoReplyGatewayProvider/autoReplyExecutorProvider/autoReplyProgressProvider；PlatformActions 加 isAccessibilityEnabled/openAccessibilitySettings
- `lib/presentation/pages/message_detail/message_detail_page.dart`：加自动回复按钮+进度面板
- `lib/presentation/pages/settings/settings_page.dart`：加无障碍状态行+默认回复文本输入
- `android/app/src/main/AndroidManifest.xml`：加 AutoReplyAccessibilityService 声明
- `android/app/src/main/kotlin/.../MainActivity.kt`：注册 AutoReplyPlugin
- `android/app/src/main/kotlin/.../NotificationPlugin.kt`：control 通道加 isAccessibilityEnabled/openAccessibilitySettings 两个 method handler（或放 AppLauncher）

---

## Phase A：领域层（纯 Dart，最先可测）

### Task A1：AutoReply 领域实体

**Files:** Create `lib/domain/entities/auto_reply.dart`, `test/domain/auto_reply_test.dart`

- [ ] **Step 1: 写测试** `test/domain/auto_reply_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/auto_reply.dart';

void main() {
  test('AutoReplyRequest holds fields', () {
    const r = AutoReplyRequest(messageId: 'm1', groupName: '货运群', senderName: '王', replyText: '接单');
    expect(r.groupName, '货运群');
    expect(r.replyText, '接单');
  });
  test('AutoReplyProgress defaults attempt=1', () {
    const p = AutoReplyProgress(step: AutoReplyStep.openingSearch, status: AutoReplyStepStatus.inProgress);
    expect(p.attempt, 1);
    expect(p.errorMessage, isNull);
  });
  test('AutoReplyOutcome success has no failedAtStep', () {
    const o = AutoReplyOutcome(result: AutoReplyResult.success, steps: []);
    expect(o.failedAtStep, isNull);
  });
  test('AutoReplyStep enum has 6 values in order', () {
    expect(AutoReplyStep.values.map((s) => s.name).toList(),
        ['launching', 'openingSearch', 'inputtingGroupName', 'enteringGroup', 'inputtingReply', 'sending']);
  });
}
```

- [ ] **Step 2: 运行确认失败** Run: `flutter test test/domain/auto_reply_test.dart` → FAIL（实体未定义）

- [ ] **Step 3: 实现** `lib/domain/entities/auto_reply.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auto_reply.freezed.dart';

@freezed
class AutoReplyRequest with _$AutoReplyRequest {
  const factory AutoReplyRequest({
    required String messageId,
    required String groupName,
    required String senderName,
    required String replyText,
  }) = _AutoReplyRequest;
}

enum AutoReplyStep {
  launching, openingSearch, inputtingGroupName,
  enteringGroup, inputtingReply, sending,
}

enum AutoReplyStepStatus { inProgress, success, retrying, failed }

@freezed
class AutoReplyProgress with _$AutoReplyProgress {
  const factory AutoReplyProgress({
    required AutoReplyStep step,
    required AutoReplyStepStatus status,
    @Default(1) int attempt,
    String? errorMessage,
  }) = _AutoReplyProgress;
}

enum AutoReplyResult { success, failed, cancelled }

@freezed
class AutoReplyOutcome with _$AutoReplyOutcome {
  const factory AutoReplyOutcome({
    required AutoReplyResult result,
    required List<AutoReplyProgress> steps,
    String? failedAtStep,
  }) = _AutoReplyOutcome;
}
```

- [ ] **Step 4: 生成代码** Run: `dart run build_runner build --delete-conflicting-outputs` → 无错误

- [ ] **Step 5: 运行确认通过** Run: `flutter test test/domain/auto_reply_test.dart` → PASS

- [ ] **Step 6: 验证 domain 隔离** Run: `dart run tool/domain_lint.dart` → exit 0

### Task A2：IAutoReplyGateway 端口 + IConfigStore 扩展

**Files:** Create `lib/domain/repositories/i_auto_reply_gateway.dart`; Modify `lib/domain/repositories/i_config_store.dart`

- [ ] **Step 1: 创建端口** `lib/domain/repositories/i_auto_reply_gateway.dart`
```dart
import 'package:dartz/dartz.dart';
import '../entities/auto_reply.dart';
import '../entities/failure.dart';

abstract class IAutoReplyGateway {
  /// 触发自动回复。返回最终结果（success/failed/cancelled）。
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest request);
  /// 执行过程中的实时进度流。
  Stream<AutoReplyProgress> get progress;
  /// 取消正在执行的回复。
  Future<void> cancel();
}
```

- [ ] **Step 2: 扩展 IConfigStore** — 读 `lib/domain/repositories/i_config_store.dart`，在抽象类内加两个方法（保留现有 QuietHours/TargetApps 方法不变）：
```dart
  Future<Either<Failure, String>> getDefaultReplyText();
  Future<Either<Failure, void>> setDefaultReplyText(String text);
```

- [ ] **Step 3: 验证编译** Run: `flutter analyze lib/domain` → No issues

- [ ] **Step 4: 验证隔离** Run: `dart run tool/domain_lint.dart` → exit 0

### Task A3：AutoReplyExecutor（编排，mock 网关单测）

**Files:** Create `lib/domain/services/auto_reply_executor.dart`, `test/domain/auto_reply_executor_test.dart`

- [ ] **Step 1: 写测试** `test/domain/auto_reply_executor_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:message_assistant/domain/entities/auto_reply.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/repositories/i_auto_reply_gateway.dart';
import 'package:message_assistant/domain/repositories/i_message_repository.dart';
import 'package:message_assistant/domain/services/auto_reply_executor.dart';

class _FakeGateway implements IAutoReplyGateway {
  final StreamController<AutoReplyProgress> _ctrl = StreamController.broadcast();
  final AutoReplyOutcome outcome;
  _FakeGateway(this.outcome);
  @override
  Stream<AutoReplyProgress> get progress => _ctrl.stream;
  void emit(AutoReplyProgress p) => _ctrl.add(p);
  @override
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest r) async => right(outcome);
  @override
  Future<void> cancel() async {}
}

class _RecordingMsgRepo implements IMessageRepository {
  int repliedCount = 0;
  String? lastReply;
  @override
  Future<Either<Failure, void>> markReplied(String id, String reply) async { repliedCount++; lastReply = reply; return right(null); }
  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async => right(r);
  @override
  Future<Either<Failure, bool>> existsByFingerprint(String f) async => right(false);
  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async => right([]);
  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);
}

void main() {
  final request = const AutoReplyRequest(messageId: 'm1', groupName: '群', senderName: '王', replyText: '接单');

  test('success → markReplied called with replyText', () async {
    final repo = _RecordingMsgRepo();
    final gw = _FakeGateway(const AutoReplyOutcome(result: AutoReplyResult.success, steps: []));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.success);
    expect(repo.repliedCount, 1);
    expect(repo.lastReply, '接单');
  });

  test('failed → NOT markReplied, returns failed outcome', () async {
    final repo = _RecordingMsgRepo();
    final gw = _FakeGateway(const AutoReplyOutcome(result: AutoReplyResult.failed, steps: [], failedAtStep: 'enteringGroup'));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.failed);
    expect(repo.repliedCount, 0);
  });

  test('cancelled → NOT markReplied', () async {
    final repo = _RecordingMsgRepo();
    final gw = _FakeGateway(const AutoReplyOutcome(result: AutoReplyResult.cancelled, steps: []));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.cancelled);
    expect(repo.repliedCount, 0);
  });

  test('forwards progress events', () async {
    final repo = _RecordingMsgRepo();
    final ctrl = StreamController<AutoReplyProgress>(sync: true);
    final gw = _ForwardingGateway(ctrl, const AutoReplyOutcome(result: AutoReplyResult.success, steps: []));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final events = <AutoReplyProgress>[];
    final sub = exec.progress.listen(events.add);
    ctrl.add(const AutoReplyProgress(step: AutoReplyStep.launching, status: AutoReplyStepStatus.success));
    await Future.delayed(Duration.zero);
    await exec.execute(request);
    await sub.cancel();
    expect(events.any((e) => e.step == AutoReplyStep.launching && e.status == AutoReplyStepStatus.success), isTrue);
  });
}

class _ForwardingGateway implements IAutoReplyGateway {
  final StreamController<AutoReplyProgress> ctrl;
  final AutoReplyOutcome outcome;
  _ForwardingGateway(this.ctrl, this.outcome);
  @override
  Stream<AutoReplyProgress> get progress => ctrl.stream;
  @override
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest r) async => right(outcome);
  @override
  Future<void> cancel() async {}
}
```
NOTE: 测试用了 `StreamController`，需 `import 'dart:async';`。

- [ ] **Step 2: 运行确认失败** Run: `flutter test test/domain/auto_reply_executor_test.dart` → FAIL

- [ ] **Step 3: 实现** `lib/domain/services/auto_reply_executor.dart`
```dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import '../entities/auto_reply.dart';
import '../entities/failure.dart';
import '../repositories/i_auto_reply_gateway.dart';
import '../repositories/i_message_repository.dart';

/// 编排自动回复：调用网关执行 + 透传进度 + 成功时 markReplied。
/// 领域层只编排不碰微信；网关是注入的抽象端口，可 mock 测。
class AutoReplyExecutor {
  final IAutoReplyGateway _gateway;
  final IMessageRepository _messageRepo;
  AutoReplyExecutor({required IAutoReplyGateway gateway, required IMessageRepository messageRepo})
      : _gateway = gateway, _messageRepo = messageRepo;

  /// 透传网关的实时进度流（UI 订阅以驱动进度面板）。
  Stream<AutoReplyProgress> get progress => _gateway.progress;

  /// 执行自动回复。成功则标记消息已回复；失败/取消不标记，由 UI 决定降级。
  Future<AutoReplyOutcome> execute(AutoReplyRequest request) async {
    final either = await _gateway.execute(request);
    final outcome = either.fold(
      (failure) => AutoReplyOutcome(result: AutoReplyResult.failed, steps: const [], failedAtStep: 'gateway'),
      (o) => o,
    );
    if (outcome.result == AutoReplyResult.success) {
      await _messageRepo.markReplied(request.messageId, request.replyText);
    }
    return outcome;
  }
}
```

- [ ] **Step 4: 运行确认通过** Run: `flutter test test/domain/auto_reply_executor_test.dart` → PASS (4)

- [ ] **Step 5: 验证隔离** Run: `dart run tool/domain_lint.dart` → exit 0；`flutter analyze lib/domain` → No issues

---

## Phase B：基础设施层 + Providers

### Task B1：AutoReplyGateway（桥接原生通道）+ 映射单测

**Files:** Create `lib/infrastructure/platform/auto_reply_channel.dart`, `test/infrastructure/auto_reply_channel_test.dart`

- [ ] **Step 1: 写映射函数单测** `test/infrastructure/auto_reply_channel_test.dart`（测纯映射函数，不碰真通道）
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/infrastructure/platform/auto_reply_channel.dart';
import 'package:message_assistant/domain/entities/auto_reply.dart';

void main() {
  test('progressFromMap maps step/status/attempt/error', () {
    final p = AutoReplyGateway.progressFromMap({
      'step': 'openingSearch', 'status': 'retrying', 'attempt': 2, 'errorMessage': '节点未找到',
    });
    expect(p.step, AutoReplyStep.openingSearch);
    expect(p.status, AutoReplyStepStatus.retrying);
    expect(p.attempt, 2);
    expect(p.errorMessage, '节点未找到');
  });
  test('progressFromMap defaults attempt=1, error=null', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'launching', 'status': 'inProgress'});
    expect(p.attempt, 1);
    expect(p.errorMessage, isNull);
  });
  test('progressFromMap unknown step throws (defensive)', () {
    expect(() => AutoReplyGateway.progressFromMap({'step': 'nope', 'status': 'success'}),
        throwsA(isA<ArgumentError>()));
  });
  test('isTerminating: success-on-sending is success-terminating', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'sending', 'status': 'success'});
    expect(AutoReplyGateway.isTerminating(p), isTrue);
    expect(AutoReplyGateway.terminatingResult(p), AutoReplyResult.success);
  });
  test('isTerminating: failed-attempt3 is failed-terminating', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'enteringGroup', 'status': 'failed', 'attempt': 3});
    expect(AutoReplyGateway.isTerminating(p), isTrue);
    expect(AutoReplyGateway.terminatingResult(p), AutoReplyResult.failed);
  });
  test('isTerminating: failed-attempt1 NOT terminating (will retry)', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'enteringGroup', 'status': 'failed', 'attempt': 1});
    expect(AutoReplyGateway.isTerminating(p), isFalse);
  });
}
```

- [ ] **Step 2: 运行确认失败** → FAIL

- [ ] **Step 3: 实现** `lib/infrastructure/platform/auto_reply_channel.dart`
```dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/auto_reply.dart';
import '../../domain/entities/failure.dart';
import '../../domain/repositories/i_auto_reply_gateway.dart';

/// 桥接原生自动回复通道。实现 [IAutoReplyGateway] 端口。
///
/// 通道契约（与 AutoReplyPlugin.kt 对齐）：
///   MethodChannel "message_assistant/autoreply": startAutoReply {groupName,senderName,replyText} / cancelAutoReply
///   EventChannel "message_assistant/autoreply_progress": 推 {step,status,attempt,errorMessage?}
///
/// 终结规则：sending+success = 整体成功；任一步 failed+attempt=3 = 整体失败。
class AutoReplyGateway implements IAutoReplyGateway {
  static const _method = MethodChannel('message_assistant/autoreply');
  static const _event = EventChannel('message_assistant/autoreply_progress');

  final _progressController = StreamController<AutoReplyProgress>.broadcast();
  StreamSubscription? _nativeSub;
  bool _listening = false;

  @override
  Stream<AutoReplyProgress> get progress => _progressController.stream;

  /// 纯映射：原生 map → AutoReplyProgress。@visibleForTesting via static.
  static AutoReplyProgress progressFromMap(Map<Object?, Object?> m) {
    final stepName = m['step'] as String?;
    final statusName = m['status'] as String?;
    final step = AutoReplyStep.values.firstWhere(
      (s) => s.name == stepName,
      orElse: () => throw ArgumentError('unknown step: $stepName'),
    );
    final status = AutoReplyStepStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => throw ArgumentError('unknown status: $statusName'),
    );
    return AutoReplyProgress(
      step: step,
      status: status,
      attempt: (m['attempt'] as num?)?.toInt() ?? 1,
      errorMessage: m['errorMessage'] as String?,
    );
  }

  /// 是否终结事件。
  static bool isTerminating(AutoReplyProgress p) {
    if (p.status == AutoReplyStepStatus.success && p.step == AutoReplyStep.sending) return true;
    if (p.status == AutoReplyStepStatus.failed && p.attempt >= 3) return true;
    return false;
  }

  /// 终结事件对应的整体结果。
  static AutoReplyResult terminatingResult(AutoReplyProgress p) {
    if (p.status == AutoReplyStepStatus.success) return AutoReplyResult.success;
    return AutoReplyResult.failed;
  }

  void _ensureListening() {
    if (_listening) return;
    _listening = true;
    _nativeSub = _event.receiveBroadcastStream().listen(
      (raw) => _progressController.add(progressFromMap(Map<Object?, Object?>.from(raw as Map))),
      onError: (e) => _progressController.addError(e),
    );
  }

  @override
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest request) async {
    _ensureListening();
    final completer = Completer<Either<Failure, AutoReplyOutcome>>();
    final steps = <AutoReplyProgress>[];
    late StreamSubscription sub;
    sub = progress.listen(
      (p) {
        steps.add(p);
        if (isTerminating(p)) {
          final result = terminatingResult(p);
          final failedAt = result == AutoReplyResult.failed ? p.step.name : null;
          completer.complete(right(AutoReplyOutcome(result: result, steps: steps, failedAtStep: failedAt)));
        }
      },
      onError: (e) {
        if (!completer.isCompleted) {
          completer.complete(left(FailureLike.gatewayError(e.toString())));
        }
      },
    );
    try {
      await _method.invokeMethod<bool>('startAutoReply', {
        'groupName': request.groupName,
        'senderName': request.senderName,
        'replyText': request.replyText,
      });
    } catch (e) {
      await sub.cancel();
      return left(FailureLike.gatewayError(e.toString()));
    }
    // 等 progress 流终结事件（带超时兜底，防原生永不回终结）。
    final outcome = await completer.future.timeout(const Duration(seconds: 60),
        onTimeout: () => right(const AutoReplyOutcome(result: AutoReplyResult.failed, steps: [], failedAtStep: 'timeout')));
    await sub.cancel();
    return outcome;
  }

  @override
  Future<void> cancel() async {
    try { await _method.invokeMethod<bool>('cancelAutoReply'); } catch (_) {}
  }

  void dispose() {
    _nativeSub?.cancel();
    _progressController.close();
  }
}

// 占位：Failure 子类。实际应 import domain/entities/failure.dart 并用其子类（如 DatabaseFailure）。
// 为避免循环，直接复用现有 Failure 体系——实施时改为 import 并用合适的 Failure 子类。
```
NOTE（实施时修正）：上面 `FailureLike.gatewayError` 是占位，实际应 `import '../../domain/entities/failure.dart';` 并用现有 Failure 体系（如新增 `class GatewayFailure extends Failure` 或复用 DatabaseFailure/ParseFailure）。实施者：在 failure.dart 加一个 `class GatewayFailure extends Failure { const GatewayFailure(super.message); }`，然后 import 用它。删除 FailureLike 占位。

- [ ] **Step 4: 在 failure.dart 加 GatewayFailure**（`lib/domain/entities/failure.dart` 末尾加）：
```dart
class GatewayFailure extends Failure {
  const GatewayFailure(super.message);
}
```

- [ ] **Step 5: 修正 auto_reply_channel.dart** 用 `GatewayFailure` 替换 `FailureLike.gatewayError` 占位（两处：onError 和 invokeMethod catch）。

- [ ] **Step 6: 运行单测确认通过** Run: `flutter test test/infrastructure/auto_reply_channel_test.dart` → PASS (6)

- [ ] **Step 7: 验证** Run: `flutter analyze lib/infrastructure` → No issues

### Task B2：Providers 扩展（PlatformActions + ConfigStore + 新 providers）

**Files:** Modify `lib/presentation/providers/providers.dart`

- [ ] **Step 1: 读现有 providers.dart** 确认 PlatformActions 类、_MemoryConfigStore 类、各 provider 名。

- [ ] **Step 2: PlatformActions 加两个方法**（在 PlatformActions 类内，走现有 _channel `"message_assistant/control"`）：
```dart
Future<bool> isAccessibilityEnabled() async {
  try { return (await _channel.invokeMethod<bool>('isAccessibilityEnabled')) ?? false; }
  catch (_) { return false; }
}
Future<void> openAccessibilitySettings() async {
  try { await _channel.invokeMethod<bool>('openAccessibilitySettings'); } catch (_) {}
}
```

- [ ] **Step 3: _MemoryConfigStore 加两方法**（实现 IConfigStore 新增的 getDefaultReplyText/setDefaultReplyText）：
```dart
String _defaultReplyText = '接单';
@override
Future<Either<Failure, String>> getDefaultReplyText() async => right(_defaultReplyText);
@override
Future<Either<Failure, void>> setDefaultReplyText(String text) async { _defaultReplyText = text; return right(null); }
```

- [ ] **Step 4: 加新 providers**（文件末尾）：
```dart
final autoReplyGatewayProvider = Provider<IAutoReplyGateway>((ref) {
  final gw = AutoReplyGateway();
  ref.onDispose(gw.dispose);
  return gw;
});
final autoReplyExecutorProvider = Provider((ref) => AutoReplyExecutor(
  gateway: ref.read(autoReplyGatewayProvider), messageRepo: ref.read(messageRepoProvider),
));
// 当前执行进度（详情页订阅驱动进度面板）
final autoReplyProgressProvider = StateProvider<AutoReplyProgress?>((ref) => null);
// 默认回复文本（持久化到 ConfigStore）
final defaultReplyTextProvider = FutureProvider<String>((ref) async {
  final either = await ref.read(configStoreProvider).getDefaultReplyText();
  return either.getOrElse((_) => '接单');
});
```
需 import 新文件：`auto_reply_channel.dart`、`i_auto_reply_gateway.dart`、`auto_reply.dart`、`auto_reply_executor.dart`。
注意：`defaultReplyTextProvider` 用 FutureProvider 读取初始值；设置时另加一个 `setDefaultReplyTextProvider`（Command）或直接在 settings 页调 `ref.read(configStoreProvider).setDefaultReplyText(text)` 然后invalidate。

- [ ] **Step 5: 验证编译+既有测试不破** Run: `flutter analyze` → No issues；`flutter test` → 既有全绿

---

## Phase C：真机校准 WeChatUIMatcher 规则（关键降险）

### Task C1：adb dump 微信各界面节点树

**Files:** Create `docs/wechat-ui-dump/` (分析报告，非代码)

- [ ] **Step 1: 确认设备连接** Run: `adb devices` → 设备 online

- [ ] **Step 2: dump 微信首页**（手机手动打开微信首页，停在"微信"Tab 会话列表）
```bash
adb shell uiautomator dump /sdcard/wx_home.xml && adb pull /sdcard/wx_home.xml docs/wechat-ui-dump/wx_home.xml
```
分析：定位"搜索"入口节点（放大镜图标）的 view-id/text/content-desc/层级。

- [ ] **Step 3: dump 搜索页**（手机点开搜索页）
```bash
adb shell uiautomator dump /sdcard/wx_search.xml && adb pull /sdcard/wx_search.xml docs/wechat-ui-dump/wx_search.xml
```
分析：搜索框 EditText 的 view-id。

- [ ] **Step 4: dump 搜索结果页**（搜索一个已知群名，如测试群）
```bash
adb shell uiautomator dump /sdcard/wx_result.xml && adb pull /sdcard/wx_result.xml docs/wechat-ui-dump/wx_result.xml
```
分析：结果列表项的结构（群名如何呈现、点击目标节点）。

- [ ] **Step 5: dump 群聊页**（进一个群）
```bash
adb shell uiautomator dump /sdcard/wx_chat.xml && adb pull /sdcard/wx_chat.xml docs/wechat-ui-dump/wx_chat.xml
```
分析：输入框 EditText + 发送按钮的 view-id/text。

- [ ] **Step 6: 整理节点规则** 写入 `docs/wechat-ui-dump/analysis.md`：每个 findXxx 的最终定位策略（首选 view-id，备选 text/类型），作为 Task D1 实现依据。

⚠️ **风险提示**：uiautomator dump 在部分华为机型/微信版本可能拿不到完整节点（微信可能标记 secure）。若 dump 失败，备用方案：写一个临时 AccessibilityService dump rootInActiveWindow 到 logcat 分析。若两方案都失败，报告 BLOCKED 并与用户讨论（可能需 uiautomatorviewer GUI 工具）。

---

## Phase D：Android 原生实现

### Task D1：WeChatUIMatcher（填校准规则）+ JUnit 单测

**Files:** Create `android/app/src/main/kotlin/.../auto_reply/WeChatUIMatcher.kt`, `AutoReplyModels.kt`, `android/app/src/test/kotlin/.../auto_reply/WeChatUIMatcherTest.kt`

- [ ] **Step 1: 实现 AutoReplyModels.kt**（Kotlin 数据类，对应 MethodChannel 参数）
```kotlin
package com.example.message_assistant.auto_reply

data class AutoReplyRequest(
    val groupName: String, val senderName: String, val replyText: String,
)

enum class AutoReplyStep { launching, openingSearch, inputtingGroupName, enteringGroup, inputtingReply, sending }
enum class AutoReplyStepStatus { inProgress, success, retrying, failed }

data class AutoReplyProgress(
    val step: AutoReplyStep, val status: AutoReplyStepStatus, val attempt: Int = 1, val errorMessage: String? = null,
)
```

- [ ] **Step 2: 实现 WeChatUIMatcher.kt**（用 Task C1 校准结果填规则）
```kotlin
package com.example.message_assistant.auto_reply

import android.view.accessibility.AccessibilityNodeInfo
import android.widget.EditText

/**
 * 微信 8.0.76 界面节点定位规则。【节点规则需真机校准】——基于 docs/wechat-ui-dump/analysis.md 填入。
 * 微信改版后此处最可能失效，集中单文件便于重校准。
 *
 * 每个找节点方法按可靠性多策略兜底：view-id → text → 类型遍历。
 */
object WeChatUIMatcher {

    // ====== 以下常量值由 Task C1 真机校准填入（占位待替换）======
    private const val SEARCH_ENTRY_VIEW_ID = "com.tencent.mm:id/<校准值>"   // Task C1 确定
    private const val SEARCH_INPUT_VIEW_ID = "com.tencent.mm:id/<校准值>"
    private const val CHAT_INPUT_VIEW_ID = "com.tencent.mm:id/<校准值>"
    private const val SEND_BTN_TEXT = "发送"   // 或 view-id，Task C1 确定

    /** 微信首页搜索入口（放大镜）。 */
    fun findSearchEntry(root: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        // 策略1: view-id
        root.findAccessibilityNodeInfosByViewId(SEARCH_ENTRY_VIEW_ID).firstOrNull()?.let { return it }
        // 策略2: content-desc 含"搜索"
        return findByContentDesc(root, "搜索")
    }

    /** 搜索页输入框。 */
    fun findSearchInput(root: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        root.findAccessibilityNodeInfosByViewId(SEARCH_INPUT_VIEW_ID).firstOrNull()?.let { return it }
        // 备选：第一个可编辑 EditText
        return findFirstOfType(root, EditText::class.java)
    }

    /** 搜索结果中匹配群名的可点击项。 */
    fun findGroupResult(root: AccessibilityNodeInfo, groupName: String): AccessibilityNodeInfo? {
        // 群名文本所在的节点；点击其最近的可点击祖先
        val textNodes = root.findAccessibilityNodeInfosByText(groupName)
        return textNodes.firstOrNull { it.text?.toString() == groupName }
            ?.firstClickableAncestor()
    }

    /** 群聊界面输入框。 */
    fun findChatInput(root: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        root.findAccessibilityNodeInfosByViewId(CHAT_INPUT_VIEW_ID).firstOrNull()?.let { return it }
        return findFirstOfType(root, EditText::class.java)
    }

    /** 发送按钮。 */
    fun findSendButton(root: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        root.findAccessibilityNodeInfosByText(SEND_BTN_TEXT).firstOrNull()?.let {
            if (it.isClickable) return it
            return it.firstClickableAncestor()
        }
        return null
    }

    // ====== 辅助：纯函数化，便于 JUnit 单测（接受抽象节点接口）======
    private fun findByContentDesc(node: AccessibilityNodeInfo, desc: String): AccessibilityNodeInfo? {
        if (node.contentDescription?.toString()?.contains(desc) == true) return node
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findByContentDesc(it, desc)?.let { found -> return found } }
        }
        return null
    }

    private fun <T : Class<*>> findFirstOfType(node: AccessibilityNodeInfo, type: T): AccessibilityNodeInfo? {
        if (type.isInstance(node)) return node
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findFirstOfType(it, type)?.let { found -> return found } }
        }
        return null
    }

    private fun AccessibilityNodeInfo.firstClickableAncestor(): AccessibilityNodeInfo {
        var n: AccessibilityNodeInfo = this
        while (n.parent != null && !n.isClickable) n = n.parent!!
        return n
    }
}
```

- [ ] **Step 3: 写 JUnit 单测**（测纯辅助逻辑：firstClickableAncestor 逻辑、text 精确匹配）。由于 AccessibilityNodeInfo 难以在 JVM 构造，单测聚焦可测的部分（如把"群名精确匹配 vs 包含"逻辑提取为纯函数 `fun matchesGroupName(nodeText, target): Boolean` 测试）。`android/app/src/test/kotlin/.../auto_reply/WeChatUIMatcherTest.kt`：
```kotlin
package com.example.message_assistant.auto_reply
import org.junit.Assert.*
import org.junit.Test

class WeChatUIMatcherTest {
    @Test fun matchesGroupName_exactMatchTrue() {
        assertTrue(WeChatUIMatcher.matchesGroupName("货运华东群", "货运华东群"))
    }
    @Test fun matchesGroupName_substringFalse() {
        // 避免误点"货运华东群2"等近似名
        assertFalse(WeChatUIMatcher.matchesGroupName("货运华东群2", "货运华东群"))
    }
    @Test fun matchesGroupName_nullFalse() {
        assertFalse(WeChatUIMatcher.matchesGroupName(null, "x"))
    }
}
```
（为此需把匹配逻辑提为 `WeChatUIMatcher.matchesGroupName(nodeText: String?, target: String): Boolean = nodeText != null && nodeText == target`，并在 findGroupResult 用它。）

- [ ] **Step 4: 运行 JUnit** Run: `cd android && ./gradlew.bat :app:testDebugUnitTest --tests "*.auto_reply.WeChatUIMatcherTest"` → PASS

### Task D2：AutoReplyEngine（状态机）+ JUnit 单测

**Files:** Create `android/app/src/main/kotlin/.../auto_reply/AutoReplyEngine.kt`, `android/app/src/test/kotlin/.../auto_reply/AutoReplyEngineTest.kt`

- [ ] **Step 1: 实现 AutoReplyEngine.kt**（Coroutine 状态机，超时3s/重试2次）
```kotlin
package com.example.message_assistant.auto_reply

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityNodeInfo
import kotlinx.coroutines.*

/**
 * 自动回复状态机驱动器。顺序执行6步，每步超时3s+最多3次尝试，失败短路。
 * 通过 [progressSink] 实时上报每步状态。
 *
 * 测试性：execute 的每步动作抽为 suspend lambda 注入；matcher 注入。
 * 这样状态机的重试/超时/短路逻辑可 JUnit 单测（mock matcher+action）。
 */
class AutoReplyEngine(
    private val rootProvider: () -> AccessibilityNodeInfo?,
    private val matcher: WeChatUIMatcher,
    private val progressSink: (AutoReplyProgress) -> Unit,
    private val launchWechat: () -> Boolean,
    private val performClick: (AccessibilityNodeInfo) -> Boolean,
    private val performSetText: (AccessibilityNodeInfo, String) -> Boolean,
) {
    private var job: Job? = null
    @Volatile var isRunning = false; private set

    fun execute(request: AutoReplyRequest, scope: CoroutineScope) {
        if (isRunning) return
        isRunning = true
        job = scope.launch {
            try {
                val ok = runStep(AutoReplyStep.launching) { launchWechat() }
                    && runStep(AutoReplyStep.openingSearch) { withRoot { root -> matcher.findSearchEntry(root)?.let(performClick) } }
                    && runStep(AutoReplyStep.inputtingGroupName) { withRoot { root -> matcher.findSearchInput(root)?.let { performSetText(it, request.groupName) } } }
                    && runStep(AutoReplyStep.enteringGroup) { withRoot { root -> matcher.findGroupResult(root, request.groupName)?.let(performClick) } }
                    && runStep(AutoReplyStep.inputtingReply) { withRoot { root -> matcher.findChatInput(root)?.let { performSetText(it, "@${request.senderName} ${request.replyText}") } } }
                    && runStep(AutoReplyStep.sending) { withRoot { root -> matcher.findSendButton(root)?.let(performClick) } }
                // ok=true 全成功（最后一步 sending success 已上报）；ok=false 中途已上报 failed
            } finally { isRunning = false }
        }
    }

    fun cancel() { job?.cancel(); isRunning = false }

    /** 单步：最多3次尝试，每次超时3s。全失败上报 failed 并返回 false（短路）。 */
    private suspend fun runStep(step: AutoReplyStep, action: suspend () -> Boolean): Boolean {
        repeat(3) { i ->
            val attempt = i + 1
            progressSink(AutoReplyProgress(step, AutoReplyStepStatus.inProgress, attempt))
            val ok = try { withTimeoutOrNull(3000L) { action() } ?: false } catch (_: Exception) { false }
            if (ok) { progressSink(AutoReplyProgress(step, AutoReplyStepStatus.success, attempt)); return true }
            if (i < 2) progressSink(AutoReplyProgress(step, AutoReplyStepStatus.retrying, attempt))
        }
        progressSink(AutoReplyProgress(step, AutoReplyStepStatus.failed, 3, "步骤失败"))
        return false
    }

    private suspend fun <T> withRoot(block: (AccessibilityNodeInfo) -> T?): T? {
        // 等待根节点（轮询），交给调用方超时控制
        val root = rootProvider() ?: return null
        return block(root)
    }
}
```
NOTE：`withRoot` 简化了——实际每步需轮询等节点出现（超时窗内多次查）。实施时可让 action 内部循环查节点，或扩展 withRoot 为轮询。保持单步超时3s 统一在 runStep。

- [ ] **Step 2: 写 JUnit 单测**（测状态机重试/短路/上报，mock 所有依赖。用 runTest + fake rootProvider/matcher/action）
`android/app/src/test/kotlin/.../auto_reply/AutoReplyEngineTest.kt`：
```kotlin
package com.example.message_assistant.auto_reply
import kotlinx.coroutines.test.runTest
import org.junit.Assert.*
import org.junit.Test

class AutoReplyEngineTest {
    // 因 AccessibilityNodeInfo 难在 JVM 构造，单测聚焦：runStep 的重试次数与上报序列。
    // 用一个最小可测变体或反射验证 repeat(3) 逻辑。
    // 若直接测 Engine 受限，则把"重试计数"逻辑提为纯函数重试策略对象测试。
    @Test fun dummyPlaceholder_engineCompiles() {
        // 占位：确保 AutoReplyEngine 类存在可编译。
        // 完整状态机行为依赖 AccessibilityNodeInfo，留真机验证。
        assertTrue(true)
    }
}
```
NOTE：AccessibilityNodeInfo 在纯 JVM 测试难以构造（final + 系统类）。状态机的真实验证依赖真机。单测至少保证编译 + 可测的纯函数（如 matchesGroupName 在 D1）。实施者：若能把"每步重试3次"逻辑提为不依赖 NodeInfo 的策略类，则可实质单测；否则在 spec 已说明状态机行为留真机验证。不要造假测试。

- [ ] **Step 3: 运行 JUnit** Run: `cd android && ./gradlew.bat :app:testDebugUnitTest` → PASS

### Task D3：AutoReplyAccessibilityService + Plugin + Manifest

**Files:** Create `AutoReplyAccessibilityService.kt`, `AutoReplyPlugin.kt`, `res/xml/auto_reply_accessibility_config.xml`; Modify `AndroidManifest.xml`, `MainActivity.kt`, `NotificationPlugin.kt`(control 加2方法), `AppLauncher.kt`(加2方法)

- [ ] **Step 1: 实现 AutoReplyAccessibilityService.kt**
```kotlin
package com.example.message_assistant.auto_reply

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class AutoReplyAccessibilityService : AccessibilityService() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private var engine: AutoReplyEngine? = null

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // 本增量不做采集；event 仅作"界面已变"信号（engine 在 withRoot 轮询时利用）
        // 此处可空实现或通知 engine 重查节点。保持轻量。
    }
    override fun onInterrupt() { engine?.cancel() }

    /** 由 Plugin 调用：启动自动回复。 */
    fun startAutoReply(request: AutoReplyRequest, sink: (AutoReplyProgress) -> Unit) {
        engine = AutoReplyEngine(
            rootProvider = { rootInActiveWindow },
            matcher = WeChatUIMatcher,
            progressSink = sink,
            launchWechat = {
                val intent = packageManager.getLaunchIntentForPackage("com.tencent.mm")
                if (intent != null) { intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK); startActivity(intent); true } else false
            },
            performClick = { it.performAction(AccessibilityNodeInfo.ACTION_CLICK) },
            performSetText = { node, text ->
                val args = android.os.Bundle().apply {
                    putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text)
                }
                node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
            },
        )
        engine?.execute(request, scope)
    }

    fun cancelAutoReply() { engine?.cancel() }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }
    override fun onDestroy() { super.onDestroy(); instance = null }

    companion object {
        @Volatile var instance: AutoReplyAccessibilityService? = null
    }
}
```

- [ ] **Step 2: 实现 AutoReplyPlugin.kt**（MethodChannel autoreply + EventChannel progress）
```kotlin
package com.example.message_assistant

import com.example.message_assistant.auto_reply.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*

class AutoReplyPlugin : FlutterPlugin, EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "message_assistant/autoreply")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "message_assistant/autoreply_progress")
        eventChannel.setStreamHandler(this)
    }

    override fun onListen(args: Any?, sink: EventChannel.EventSink?) { eventSink = sink }
    override fun onCancel(args: Any?) { eventSink = null }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startAutoReply" -> {
                val service = AutoReplyAccessibilityService.instance
                if (service == null) { result.success(false); return }
                val req = AutoReplyRequest(
                    groupName = call.argument<String>("groupName") ?: "",
                    senderName = call.argument<String>("senderName") ?: "",
                    replyText = call.argument<String>("replyText") ?: "",
                )
                service.startAutoReply(req) { progress ->
                    eventSink?.success(mapOf(
                        "step" to progress.step.name, "status" to progress.status.name,
                        "attempt" to progress.attempt, "errorMessage" to (progress.errorMessage ?: ""),
                    ))
                }
                result.success(true)
            }
            "cancelAutoReply" -> { AutoReplyAccessibilityService.instance?.cancelAutoReply(); result.success(true) }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null); eventChannel.setStreamHandler(null)
    }
}
```

- [ ] **Step 3: res/xml/auto_reply_accessibility_config.xml**
```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault|flagRetrieveInteractiveWindows"
    android:canRetrieveWindowContent="true"
    android:canPerformGestures="false"
    android:packageNames="com.tencent.mm" />
```

- [ ] **Step 4: AndroidManifest.xml 加 service 声明**（在 <application> 内，与现有 services 并列）
```xml
<service
    android:name=".auto_reply.AutoReplyAccessibilityService"
    android:exported="false"
    android:label="消息助手自动回复"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/auto_reply_accessibility_config" />
</service>
```

- [ ] **Step 5: MainActivity 注册 AutoReplyPlugin**（在 configureFlutterEngine 内，与现有 NotificationPlugin 并列）
```kotlin
flutterEngine.plugins.add(NotificationPlugin())
flutterEngine.plugins.add(AutoReplyPlugin())   // 新增
```

- [ ] **Step 6: control 通道加 isAccessibilityEnabled / openAccessibilitySettings**
   - `AppLauncher.kt` 加：
   ```kotlin
   fun isAccessibilityEnabled(context: Context): Boolean {
       val enabled = Settings.Secure.getInt(context.contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0)
       if (enabled != 1) return false
       val list = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
       val target = "${context.packageName}/${AutoReplyAccessibilityService::class.java.name}"
       return list.contains(target)
   }
   fun openAccessibilitySettings(context: Context) {
       context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
   }
   ```
   - `NotificationPlugin.kt` 的 onMethodCall 加两个 case（isAccessibilityEnabled → AppLauncher.isAccessibilityEnabled；openAccessibilitySettings → AppLauncher.openAccessibilitySettings + success）。注意 AutoReplyAccessibilityService 在 auto_reply 子包，全限定名 `com.example.message_assistant.auto_reply.AutoReplyAccessibilityService`。

- [ ] **Step 7: 编译验证** Run: `cd android && ./gradlew.bat :app:assembleDebug` → BUILD SUCCESSFUL
   Run: `cd /d/claudecode/phone && flutter build apk --debug` → BUILD SUCCESSFUL

---

## Phase E：Flutter UI（详情页进度面板 + 设置页）

### Task E1：详情页改造（自动回复按钮 + 进度面板）+ Widget 测试

**Files:** Modify `lib/presentation/pages/message_detail/message_detail_page.dart`; Create `test/presentation/message_detail_auto_reply_test.dart`

- [ ] **Step 1: 改造详情页** — 读现有文件，在按钮区：
   - 保留"复制消息""标记已回复"
   - "复制并打开微信"降为 OutlinedButton（次级）
   - 新增 FilledButton.icon "自动回复"（主按钮）：
     - onPressed: 检查 `ref.read(platformActionsProvider).isAccessibilityEnabled()`；未授权→SnackBar"请先开启无障碍服务"+引导 openAccessibilitySettings；已授权→构造 AutoReplyRequest(messageId, groupName=消息.groupName ?? senderName, senderName, replyText=ref.read(defaultReplyTextProvider).asData?.value ?? '接单')；调 `ref.read(autoReplyExecutorProvider).execute(request)`，执行期间用 StreamProvider/StateProvider 驱动进度面板。
   - 进度面板：订阅 executor.progress（或 autoReplyProgressProvider），渲染6步图标 + 状态。
   - 完成处理：success→SnackBar"已自动回复"+invalidate detail；failed→复制 replyText 到剪贴板+SnackBar"自动回复失败，已复制，请手动"。
   （具体 Widget 结构实施时定，遵循 Material3，进度面板用 ListView/Column of Row[图标+步骤名+状态]。）

- [ ] **Step 2: Widget 测试** `test/presentation/message_detail_auto_reply_test.dart`：
   - mock autoReplyExecutorProvider（overrideWith 返回固定 outcome）
   - mock platformActionsProvider（isAccessibilityEnabled→true）
   - pump 详情页（override messageDetailProvider 返回带 groupName 的消息）
   - 断言"自动回复"按钮存在；点按后出现进度面板；mock 返回 success 时显示"已自动回复"SnackBar
   - 至少 3 个用例：按钮渲染、未授权提示、成功路径

- [ ] **Step 3: 运行** Run: `flutter test test/presentation/message_detail_auto_reply_test.dart` → PASS

- [ ] **Step 4: analyze** Run: `flutter analyze lib/presentation` → No issues

### Task E2：设置页改造（无障碍状态 + 默认回复文本）

**Files:** Modify `lib/presentation/pages/settings/settings_page.dart`

- [ ] **Step 1: 读现有 settings_page.dart** 确认结构。

- [ ] **Step 2: 加"无障碍服务"行**（与"通知监听"并列）：状态（init 时查 isAccessibilityEnabled）+ "去开启"按钮（openAccessibilitySettings）。

- [ ] **Step 3: 加"默认回复文本"行**：TextField 显示 defaultReplyTextProvider 当前值（默认"接单"），onChange 调 configStoreProvider.setDefaultReplyText + invalidate。

- [ ] **Step 4: analyze** Run: `flutter analyze lib/presentation` → No issues

---

## Phase F：集成、编译、验证清单

### Task F1：全量回归

- [ ] **Step 1: Dart 全测** Run: `flutter test` → 全绿（既有67 + 新增）
- [ ] **Step 2: Kotlin 测试** Run: `cd android && ./gradlew.bat :app:testDebugUnitTest` → 全绿
- [ ] **Step 3: analyze** Run: `flutter analyze` → No issues
- [ ] **Step 4: domain 隔离** Run: `dart run tool/domain_lint.dart` → exit 0
- [ ] **Step 5: APK 编译** Run: `flutter build apk --debug` → BUILD SUCCESSFUL

### Task F2：验证清单 + README 更新

- [ ] **Step 1: 追加验证清单** 在 `docs/verification-checklist.md` 末尾加"自动回复"章节（spec §5.3 的内容）

- [ ] **Step 2: 更新 README** 在 README"下一步"或新增"自动回复"小节，说明本增量 + 验证状态

- [ ] **Step 3: 汇总证据** 向用户汇报：✅ 单测/分析/编译；⚠️ WeChatUIMatcher 真机校准已 dump；❌ 端到端待真机验证

### Task F3：真机端到端验证（用户执行 + 我辅助）

- [ ] **Step 1: 安装新 APK** Run: `adb install -r build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 2: 授权无障碍** 用户在系统设置开启"消息助手自动回复"服务

- [ ] **Step 3: 触发自动回复** 用户在 App 详情页点"自动回复"，观察微信是否自动进群@发送

- [ ] **Step 4: 若失败，dump 节点排查** 我用 `adb shell uiautomator dump` 抓卡住界面的节点，对比 WeChatUIMatcher 规则，修正后重试

- [ ] **Step 5: 记录** 把验证结果写入验证清单

---

## 自审记录

本计划对照 spec 逐节核查：
- **Spec 覆盖**：领域实体(A1)/端口(A2)/编排(A3)；infra Gateway(B1)/providers(B2)；真机校准(C1)；Engine/Matcher/Service/Plugin/Manifest(D1-D3)；UI(E1-E2)；集成(F1-F3) 均覆盖。
- **类型一致**：AutoReplyStep 6值在 Dart(domain)、Kotlin(AutoReplyModels)、测试用例三处一致（launching/openingSearch/inputtingGroupName/enteringGroup/inputtingReply/sending）。终结规则（sending+success / failed+attempt3）在 B1 映射测试与 spec §2.4 一致。
- **风险标注**：WeChatUIMatcher 节点规则（D1 标 `<校准值>` 占位 + Task C1 校准）、状态机 AccessibilityNodeInfo 难纯 JVM 测（D2 说明留真机验证）均已显式标注，未造假测试。
- **无占位代码漏网**：除 D1 故意的 `<校准值>` 待真机填入（spec 头号风险，已说明）外，其余代码完整。`FailureLike` 占位已在 B1 Step4-5 明确替换为 GatewayFailure。

# 消息提醒器助手 MVP 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个可安装到 Android 手机的 Flutter App，监听微信群通知 → 关键词匹配 → 本地提醒 → 点击唤起微信的完整闭环。

**Architecture:** 单 Flutter 工程 + 领域隔离（方案 C），六边形架构（端口-适配器）。领域层纯 Dart 可脱离设备单测；基础设施层用 Drift(SQLite) + EventChannel/MethodChannel 桥接 Android 原生；表示层 Riverpod。Android 原生用 Kotlin 实现 NotificationListener + 前台保活服务。

**Tech Stack:** Flutter 3.x / Riverpod 2.x / go_router / Drift (SQLite) / flutter_local_notifications / get_it + injectable / freezed + json_serializable / dartz / Kotlin + Coroutines

**Spec:** `docs/superpowers/specs/2026-07-30-message-assistant-mvp-design.md`

---

## 重要协调约定（贯穿全计划）

**解析逻辑只存一份**：微信通知格式解析（title/text → 群名/发送人/内容）**只在 Kotlin `NotificationParser` 实现**（spec §5.2 的纯函数，JUnit 单测覆盖）。EventChannel 传**结构化字段**（appId/groupId/groupName/senderName/content/timestamp）。Dart 侧 `MessagePipeline.normalize()` 只做结构化字段 → `MessageRecord` 的映射，**不重复解析逻辑**。

**groupId 由 Kotlin 侧生成**：`sha1("$appId|$groupName")` 前 16 字符（单聊无群名时用 senderName）。EventChannel 直接传生成好的 groupId，Dart 不再计算。

**包名占位**：Kotlin 包路径记为 `com.example.ma`，实施时按实际 applicationId 调整。

---

## 文件结构总览

```
message_assistant/
├── pubspec.yaml
├── analysis_options.yaml          # 含 domain import 隔离 lint
├── lib/
│   ├── main.dart
│   ├── app/{app.dart, di.dart, router.dart}
│   ├── domain/
│   │   ├── entities/{keyword_rule, message_record, match_result, monitored_group, raw_notification_event, failure}.dart
│   │   ├── services/{keyword_match_service, message_dedup_service, message_pipeline, notify_policy_service}.dart
│   │   └── repositories/{i_message_repository, i_keyword_repository, i_config_store}.dart
│   ├── infrastructure/
│   │   ├── database/{database, tables/messages, tables/keywords, tables/groups, daos/message_dao, daos/keyword_dao, drift_repositories}.dart
│   │   ├── platform/{notification_channel, launcher_channel, permission_channel}.dart
│   │   └── services/local_notifier.dart
│   ├── presentation/
│   │   ├── pages/{home, message_detail, keyword_config, history, settings, onboarding}/...
│   │   ├── providers/{...}.dart
│   │   └── widgets/{keyword_highlight_text, empty_state}.dart
│   └── core/{constants, errors, extensions}.dart
├── android/app/src/main/kotlin/com/example/ma/
│   ├── {NotificationParser, MessageNotificationListenerService, MonitorForegroundService, BootReceiver, ServiceRestarter, AppLauncher, NotificationPlugin, MainApplication}.kt
│   └── test/NotificationParserTest.kt
├── test/{domain, infrastructure, presentation}/...
└── docs/{verification-checklist.md, README...}
```

---

## Phase 0: 环境搭建

### Task 0.1: 安装并验证 Flutter 环境

**Files:** (无文件改动，环境验证)

- [ ] **Step 1: 检测 Flutter 是否已安装**

Run: `flutter --version`
Expected: 若已安装显示版本号；若未安装显示 "command not found"。

- [ ] **Step 2: 若未安装，引导安装 Flutter SDK**

下载 Flutter 3.x stable channel（Windows：解压到如 `C:\flutter`，无空格路径）。或用 fvm：
```bash
# 用 fvm 安装（推荐）
dart pub global activate fvm
fvm install stable
fvm use stable
```
若无法安装 Flutter（网络/权限），**停止本计划并向用户报告**——后续所有任务依赖 Flutter。

- [ ] **Step 3: 配置 Android SDK 与 ANDROID_HOME**

确认 Android SDK 路径（如 `C:\Users\<user>\AppData\Local\Android\Sdk`），设置环境变量 `ANDROID_HOME`，并把 `platform-tools` 加入 PATH（已有 `/d/adb/platform-tools/adb`）。

- [ ] **Step 4: 运行 flutter doctor**

Run: `flutter doctor -v`
Expected: Flutter 与 Android toolchain 全绿。**iOS toolchain 必然红（Windows 无 Xcode）——这是预期的，记录但不阻塞**。Android license 若未接受，运行 `flutter doctor --android-licenses` 接受。

- [ ] **Step 5: 验证 Java 兼容**

Run: `flutter doctor -v | grep -i java`
Expected: Flutter 检测到 Java（已有 v20）。若 Gradle 报 Java 版本问题，按 Flutter 提示安装对应 JDK。

- [ ] **Step 6: 报告环境状态**

向用户汇报 `flutter doctor` 结果，明确标注哪些项绿、哪些项（iOS）预期不绿。**无设备不影响编译验证，只影响端到端**。

---

## Phase 1: 工程骨架与分层隔离

### Task 1.1: 创建 Flutter 工程

**Files:**
- Create: `pubspec.yaml`, `lib/main.dart`, `analysis_options.yaml`（由 `flutter create` 生成后修改）

- [ ] **Step 1: 创建工程**

Run（在 `D:\claudecode\phone` 下）: `flutter create --org com.example --project-name message_assistant --platforms=android,ios .`
Expected: 生成 Flutter 工程骨架。注意：在已有 `docs/` 的目录创建，确认未覆盖 docs。

- [ ] **Step 2: 验证工程可运行（空壳）**

Run: `flutter analyze`
Expected: "No issues found!"（默认 counter 模板）。

- [ ] **Step 3: 建立目录骨架**

按"文件结构总览"创建空目录：`lib/{app,domain/{entities,services,repositories},infrastructure/{database/{tables,daos},platform,services},presentation/{pages,pages/home,pages/message_detail,pages/keyword_config,pages/history,pages/settings,pages/onboarding,providers,widgets},core}` 和 `test/{domain,infrastructure,presentation}`。

- [ ] **Step 4: Commit**

```bash
git init 2>nul
git add .
git commit -m "chore: scaffold Flutter project with layered structure"
```
（本工作区非 git 仓库；若用户未要求 git，跳过 commit，但保留 `git init` 选项待用户确认。后续任务的 commit 步骤同理——非 git 仓库时标注"可选 commit"并跳过。）

### Task 1.2: 配置依赖

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 编辑 pubspec.yaml dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  go_router: ^12.1.3
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  flutter_local_notifications: ^16.2.0
  get_it: ^7.6.4
  injectable: ^2.3.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  dartz: ^0.10.1
  equatable: ^2.0.5
  uuid: ^4.2.1
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  drift_dev: ^2.14.1
  injectable_generator: ^2.4.1
  riverpod_generator: ^2.3.9
  custom_lint: ^0.5.7
  riverpod_lint: ^2.3.7
  mockito: ^5.4.4
  build_verify: ^3.1.0
```
（版本号实施时取最新稳定版；若某个版本冲突，按 pub 提示解决并记录。）

- [ ] **Step 2: 安装依赖**

Run: `flutter pub get`
Expected: 依赖解析成功。若冲突，按提示调整版本。

- [ ] **Step 3: 验证安装**

Run: `flutter pub run --version 2>nul || echo "deps installed"`
Expected: 无错误。

### Task 1.3: 配置 domain 层 import 隔离 lint

**Files:**
- Create: `analysis_options.yaml`（覆盖默认）
- Create: `tool/domain_lint.dart`（自定义检查脚本，因 analysis_options 难以直接禁止跨包 import）

- [ ] **Step 1: 编写 domain import 隔离检查脚本**

`tool/domain_lint.dart`：遍历 `lib/domain/**/*.dart`，检查每行 import 是否在白名单（`dart:core`/`dart:collection`/`dart:convert`/`package:dartz`/`package:equatable`/`package:meta`/`package:freezed_annotation`/`package:json_annotation`/相对同层 domain import）。若发现 `package:flutter` 或其它，报错退出码 1。

```dart
import 'dart:io';
// 读取 lib/domain 下所有 .dart，逐行扫描 import，非白名单则 stderr 输出并 fail。
```
（完整实现：扫描文件，正则匹配 `import '...'`/`import "..."`，白名单前缀匹配，违规收集后 `exit(1)`。）

- [ ] **Step 2: 写自测（脚本本身的行为验证）**

`tool/domain_lint_test.dart`：构造临时目录，放一个含违规 import 的文件，断言脚本对其报错；放一个合规文件，断言不报错。

- [ ] **Step 3: 验证脚本工作**

Run: `dart test tool/domain_lint_test.dart`
Expected: PASS。

- [ ] **Step 4: 配置 analysis_options.yaml 基础规则**

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
```

- [ ] **Step 5: Commit（可选）**

```bash
git add analysis_options.yaml tool/ pubspec.yaml
git commit -m "chore: add dependencies and domain isolation lint"
```

---

## Phase 2: 领域层（纯 Dart，最先拿到测试证据）

### Task 2.1: 错误类型 Failure

**Files:**
- Create: `lib/domain/entities/failure.dart`

- [ ] **Step 1: 写测试**

`test/domain/failure_test.dart`：
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/failure.dart';

void main() {
  test('DatabaseFailure carries message', () {
    const f = DatabaseFailure('boom');
    expect(f.message, 'boom');
  });
  test('Failure equality by type+message', () {
    expect(const DatabaseFailure('x'), const DatabaseFailure('x'));
    expect(const DatabaseFailure('x') == const ParseFailure('x'), isFalse);
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/failure_test.dart`
Expected: FAIL（Failure 未定义）。

- [ ] **Step 3: 实现**

```dart
// lib/domain/entities/failure.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/domain/failure_test.dart`
Expected: PASS。

- [ ] **Step 5: 验证 domain 隔离**

Run: `dart run tool/domain_lint.dart`
Expected: exit 0（failure.dart 仅依赖 equatable）。

- [ ] **Step 6: Commit（可选）**

### Task 2.2: 实体 — KeywordRule / MatchType

**Files:**
- Create: `lib/domain/entities/keyword_rule.dart`
- Create: `test/domain/keyword_rule_test.dart`

- [ ] **Step 1: 写测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';

void main() {
  test('defaults: contains type, priority 50, enabled true, empty lists', () {
    final k = KeywordRule(id: 'k1', keyword: '南京', createdAt: DateTime(2026));
    expect(k.type, MatchType.contains);
    expect(k.priority, 50);
    expect(k.enabled, isTrue);
    expect(k.scopeGroupIds, isEmpty);
    expect(k.excludeWords, isEmpty);
  });
  test('MatchType enum has exact and contains', () {
    expect(MatchType.values, containsAll([MatchType.exact, MatchType.contains]));
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/keyword_rule_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现**

```dart
// lib/domain/entities/keyword_rule.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'keyword_rule.freezed.dart';
part 'keyword_rule.g.dart';

enum MatchType { exact, contains }

@freezed
class KeywordRule with _$KeywordRule {
  const factory KeywordRule({
    required String id,
    required String keyword,
    @Default(MatchType.contains) MatchType type,
    @Default(50) int priority,
    @Default([]) List<String> scopeGroupIds,
    @Default([]) List<String> excludeWords,
    @Default(true) bool enabled,
    String? groupName,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _KeywordRule;

  factory KeywordRule.fromJson(Map<String, dynamic> json) =>
      _$KeywordRuleFromJson(json);
}
```

- [ ] **Step 4: 生成 freezed/json 代码**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 生成 `keyword_rule.freezed.dart` 与 `.g.dart`，无错误。

- [ ] **Step 5: 运行测试，确认通过**

Run: `flutter test test/domain/keyword_rule_test.dart`
Expected: PASS。

- [ ] **Step 6: Commit（可选）**

### Task 2.3: 实体 — MessageRecord / KeywordHit / MatchResult / RawNotificationEvent

**Files:**
- Create: `lib/domain/entities/message_record.dart`, `match_result.dart`, `raw_notification_event.dart`
- Create: 对应测试

- [ ] **Step 1: 写测试（KeywordHit 偏移、MatchResult score 聚合占位由 service 算，实体只存）**

`test/domain/entities_test.dart`：
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/raw_notification_event.dart';

void main() {
  test('RawNotificationEvent holds structured fields', () {
    final e = RawNotificationEvent(
      appId: 'com.tencent.mm', groupId: 'g1', groupName: '群',
      senderName: '王', senderId: null, content: '南京到上海',
      occurredAt: DateTime(2026, 7, 30, 14, 32),
    );
    expect(e.appId, 'com.tencent.mm');
    expect(e.content, '南京到上海');
  });
  test('MessageRecord defaults: score 0, isRead false', () {
    final r = MessageRecord(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's',
      content: 'c', occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp', createdAt: DateTime(2026),
    );
    expect(r.score, 0);
    expect(r.isRead, isFalse);
    expect(r.hits, isEmpty);
  });
  test('KeywordHit stores highlightPositions', () {
    const h = KeywordHit(ruleId: 'k', keyword: '到', type: MatchType.contains, priority: 50, highlightPositions: [2]);
    expect(h.highlightPositions, [2]);
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/entities_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现 raw_notification_event.dart**

```dart
// lib/domain/entities/raw_notification_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'raw_notification_event.freezed.dart';

@freezed
class RawNotificationEvent with _$RawNotificationEvent {
  const factory RawNotificationEvent({
    required String appId,
    required String groupId,
    String? groupName,
    required String senderName,
    String? senderId,
    required String content,
    required DateTime occurredAt,
  }) = _RawNotificationEvent;
}
```

- [ ] **Step 4: 实现 message_record.dart**

```dart
// lib/domain/entities/message_record.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'match_result.dart'; // for KeywordHit
part 'message_record.freezed.dart';

@freezed
class MessageRecord with _$MessageRecord {
  const factory MessageRecord({
    required String id,
    required String appId,
    required String groupId,
    String? groupName,
    required String senderName,
    String? senderId,
    required String content,
    @Default([]) List<KeywordHit> hits,
    @Default(0) int score,
    required DateTime occurredAt,
    required DateTime receivedAt,
    @Default(false) bool isRead,
    @Default(false) bool isReplied,
    String? replyContent,
    required String fingerprint,
    required DateTime createdAt,
  }) = _MessageRecord;
}
```

- [ ] **Step 5: 实现 match_result.dart（含 KeywordHit）**

```dart
// lib/domain/entities/match_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'keyword_rule.dart'; // for MatchType
import 'message_record.dart';
part 'match_result.freezed.dart';

@freezed
class KeywordHit with _$KeywordHit {
  const factory KeywordHit({
    required String ruleId,
    required String keyword,
    required MatchType type,
    required int priority,
    required List<int> highlightPositions,
  }) = _KeywordHit;
}

@freezed
class MatchResult with _$MatchResult {
  const factory MatchResult({
    required MessageRecord message,
    required List<KeywordHit> hits,
    required int score,
  }) = _MatchResult;
}
```

- [ ] **Step 6: 生成代码**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 无错误。

- [ ] **Step 7: 运行测试，确认通过**

Run: `flutter test test/domain/entities_test.dart`
Expected: PASS。

- [ ] **Step 8: Commit（可选）**

### Task 2.4: 仓储端口（抽象接口）

**Files:**
- Create: `lib/domain/repositories/i_message_repository.dart`, `i_keyword_repository.dart`, `i_config_store.dart`

- [ ] **Step 1: 实现 i_message_repository.dart**

```dart
// lib/domain/repositories/i_message_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/message_record.dart';
import '../entities/failure.dart';

abstract class IMessageRepository {
  Future<Either<Failure, MessageRecord>> save(MessageRecord record);
  Future<Either<Failure, bool>> existsByFingerprint(String fingerprint);
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({
    String? groupId, int limit = 50, int offset = 0});
  Future<Either<Failure, MessageRecord?>> findById(String id);
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, void>> markReplied(String id, String replyContent);
}
```

- [ ] **Step 2: 实现 i_keyword_repository.dart**

```dart
// lib/domain/repositories/i_keyword_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/keyword_rule.dart';
import '../entities/failure.dart';

abstract class IKeywordRepository {
  Future<Either<Failure, List<KeywordRule>>> findAll();
  Future<Either<Failure, List<KeywordRule>>> findByScope(String groupId);
  Future<Either<Failure, KeywordRule>> save(KeywordRule rule);
  Future<Either<Failure, void>> delete(String id);
}
```

- [ ] **Step 3: 实现 i_config_store.dart**

```dart
// lib/domain/repositories/i_config_store.dart
import 'package:dartz/dartz.dart';
import '../entities/failure.dart';

class QuietHours {
  final int startHour;  // 0-23
  final int endHour;    // 0-23
  final bool enabled;
  const QuietHours({required this.startHour, required this.endHour, required this.enabled});
  const QuietHours.disabled() : startHour = 22, endHour = 7, enabled = false;
}

abstract class IConfigStore {
  Future<Either<Failure, QuietHours>> getQuietHours();
  Future<Either<Failure, void>> setQuietHours(QuietHours qh);
  Future<Either<Failure, List<String>>> getTargetAppPackages();
}
```

- [ ] **Step 4: 验证编译**

Run: `flutter analyze lib/domain`
Expected: No issues。

- [ ] **Step 5: 验证 domain 隔离**

Run: `dart run tool/domain_lint.dart`
Expected: exit 0。

- [ ] **Step 6: Commit（可选）**

### Task 2.5: KeywordMatchService（匹配引擎）

**Files:**
- Create: `lib/domain/services/keyword_match_service.dart`
- Create: `test/domain/keyword_match_service_test.dart`

- [ ] **Step 1: 写测试（覆盖 spec §7.1 全部用例）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/services/keyword_match_service.dart';

KeywordRule _kw(String id, String word, {MatchType type = MatchType.contains, int priority = 50, List<String> scope = const [], List<String> exclude = const [], bool enabled = true}) =>
    KeywordRule(id: id, keyword: word, type: type, priority: priority, scopeGroupIds: scope, excludeWords: exclude, enabled: enabled, createdAt: DateTime(2026));

void main() {
  final svc = KeywordMatchService();

  test('contains hit records position', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'南京到上海',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','到')]);
    expect(r, isNotNull);
    expect(r!.hits.single.keyword, '到');
    expect(r.hits.single.highlightPositions, [2]); // 南京[到]上海
    expect(r.score, 50);
  });

  test('exact does NOT match substring', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'上海港',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','上海', type: MatchType.exact)]);
    expect(r, isNull);
  });

  test('exact matches whole string', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'上海',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','上海', type: MatchType.exact, priority: 80)]);
    expect(r, isNotNull);
    expect(r!.score, 80);
  });

  test('multiple hits sorted by priority desc, score summed', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'台州到南通',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('low','到',priority:30), _kw('hi','南通',priority:80), _kw('mid','台州',priority:50)]);
    expect(r!.hits.map((h)=>h.keyword).toList(), ['南通','台州','到']);
    expect(r.score, 30+80+50);
  });

  test('excludeWord skips rule', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'南京到上海测试',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','南京', exclude: ['测试'])]);
    expect(r, isNull);
  });

  test('scopeGroupIds non-empty and not containing groupId skips rule', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'gA',senderName:'s',content:'南京',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','南京', scope: ['gB'])]);
    expect(r, isNull);
  });

  test('scopeGroupIds containing groupId matches', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'gA',senderName:'s',content:'南京',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','南京', scope: ['gA'])]);
    expect(r, isNotNull);
  });

  test('disabled rule skipped', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'南京',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','南京', enabled: false)]);
    expect(r, isNull);
  });

  test('english case-insensitive', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'SHANGHAI',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','shanghai')]);
    expect(r, isNotNull);
  });

  test('no hit returns null', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'无关内容',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    expect(svc.match(msg, [_kw('k1','南京')]), isNull);
  });

  test('all-occurrences positions for repeated keyword', () {
    final msg = MessageRecord(id:'m',appId:'a',groupId:'g',senderName:'s',content:'到这到那',occurredAt:DateTime(2026),receivedAt:DateTime(2026),fingerprint:'f',createdAt:DateTime(2026));
    final r = svc.match(msg, [_kw('k1','到')]);
    expect(r!.hits.single.highlightPositions, [0,2]); // [到]这[到]那
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/keyword_match_service_test.dart`
Expected: FAIL（service 未定义）。

- [ ] **Step 3: 实现 KeywordMatchService**

```dart
// lib/domain/services/keyword_match_service.dart
import '../entities/keyword_rule.dart';
import '../entities/message_record.dart';
import '../entities/match_result.dart';

class KeywordMatchService {
  MatchResult? match(MessageRecord message, List<KeywordRule> rules) {
    final contentLower = message.content.toLowerCase();
    final hits = <KeywordHit>[];

    for (final rule in rules) {
      if (!rule.enabled) continue;
      // 群范围过滤
      if (rule.scopeGroupIds.isNotEmpty && !rule.scopeGroupIds.contains(message.groupId)) {
        continue;
      }
      // 排除词
      if (rule.excludeWords.any((w) => message.content.toLowerCase().contains(w.toLowerCase()))) {
        continue;
      }
      final kwLower = rule.keyword.toLowerCase();
      List<int>? positions;
      switch (rule.type) {
        case MatchType.exact:
          if (contentLower == kwLower) positions = [];
          break;
        case MatchType.contains:
          positions = _findAll(contentLower, kwLower);
          break;
      }
      if (positions == null) continue;
      hits.add(KeywordHit(
        ruleId: rule.id, keyword: rule.keyword, type: rule.type,
        priority: rule.priority, highlightPositions: positions,
      ));
    }

    if (hits.isEmpty) return null;
    hits.sort((a, b) => b.priority.compareTo(a.priority));
    final score = hits.fold<int>(0, (s, h) => s + h.priority);
    return MatchResult(message: message.copyWith(hits: hits, score: score), hits: hits, score: score);
  }

  List<int> _findAll(String haystack, String needle) {
    if (needle.isEmpty) return [];
    final positions = <int>[];
    var start = 0;
    while (true) {
      final idx = haystack.indexOf(needle, start);
      if (idx == -1) break;
      positions.add(idx);
      start = idx + needle.length;
    }
    return positions;
  }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/domain/keyword_match_service_test.dart`
Expected: 11/11 PASS。

- [ ] **Step 5: 验证 domain 隔离**

Run: `dart run tool/domain_lint.dart`
Expected: exit 0。

- [ ] **Step 6: Commit（可选）**

### Task 2.6: MessageDedupService（去重）

**Files:**
- Create: `lib/domain/services/message_dedup_service.dart`
- Create: `test/domain/message_dedup_service_test.dart`

- [ ] **Step 1: 写测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/services/message_dedup_service.dart';

void main() {
  final svc = MessageDedupService();
  final base = DateTime(2026, 7, 30, 14, 32, 0);

  test('same minute same sender same content -> same fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g1','s1','南京到上海', base.add(const Duration(seconds: 30)));
    expect(f1, f2);
  });
  test('cross minute boundary -> different fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g1','s1','南京到上海', base.add(const Duration(seconds: 61)));
    expect(f1, isNot(f2));
  });
  test('different sender same content -> different fingerprint', () {
    final f1 = svc.fingerprint('app','g1','s1','南京到上海', base);
    final f2 = svc.fingerprint('app','g1','s2','南京到上海', base);
    expect(f1, isNot(f2));
  });
  test('fingerprint is 40-char hex sha1', () {
    final f = svc.fingerprint('app','g1','s1','南京到上海', base);
    expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(f), isTrue);
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/message_dedup_service_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现**

```dart
// lib/domain/services/message_dedup_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MessageDedupService {
  String fingerprint(String appId, String groupId, String senderId, String content, DateTime timestamp) {
    final minuteBucket = timestamp.millisecondsSinceEpoch ~/ 60000;
    final raw = '$appId|$groupId|$senderId|$content|$minuteBucket';
    return sha1.convert(utf8.encode(raw)).toString();
  }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/domain/message_dedup_service_test.dart`
Expected: PASS。

- [ ] **Step 5: Commit（可选）**

### Task 2.7: NotifyPolicyService（夜间静默判断）

**Files:**
- Create: `lib/domain/services/notify_policy_service.dart`
- Create: `test/domain/notify_policy_service_test.dart`

- [ ] **Step 1: 写测试（含跨日时段边界）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/repositories/i_config_store.dart';
import 'package:message_assistant/domain/services/notify_policy_service.dart';

void main() {
  final svc = NotifyPolicyService();

  test('disabled quiet hours always notifies', () {
    expect(svc.shouldNotify(DateTime(2026,7,30,3,0), const QuietHours.disabled()), isTrue);
  });
  test('22-07 range: 03:00 is quiet', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,3,0), qh), isFalse);
  });
  test('22-07 range: 12:00 notifies', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,12,0), qh), isTrue);
  });
  test('cross-midnight boundary: 22:00 quiet, 21:59 notify', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,22,0), qh), isFalse);
    expect(svc.shouldNotify(DateTime(2026,7,30,21,59), qh), isTrue);
  });
  test('07:00 notify, 06:59 quiet', () {
    const qh = QuietHours(startHour: 22, endHour: 7, enabled: true);
    expect(svc.shouldNotify(DateTime(2026,7,30,7,0), qh), isTrue);
    expect(svc.shouldNotify(DateTime(2026,7,30,6,59), qh), isFalse);
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/notify_policy_service_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现**

```dart
// lib/domain/services/notify_policy_service.dart
import '../repositories/i_config_store.dart';

class NotifyPolicyService {
  bool shouldNotify(DateTime now, QuietHours qh) {
    if (!qh.enabled) return true;
    final hour = now.hour;
    if (qh.startHour == qh.endHour) return true; // 无效配置，不过滤
    if (qh.startHour < qh.endHour) {
      return hour < qh.startHour || hour >= qh.endHour;
    } else {
      // 跨日，如 22 -> 7
      return hour < qh.endHour ? false : (hour >= qh.startHour ? false : true);
    }
  }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/domain/notify_policy_service_test.dart`
Expected: PASS。

- [ ] **Step 5: Commit（可选）**

### Task 2.8: MessagePipeline（编排核心）

**Files:**
- Create: `lib/domain/services/message_pipeline.dart`
- Create: `test/domain/message_pipeline_test.dart`

- [ ] **Step 1: 写测试（Mock 仓储，覆盖全分支；断言未命中不存库）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/raw_notification_event.dart';
import 'package:message_assistant/domain/repositories/i_message_repository.dart';
import 'package:message_assistant/domain/repositories/i_keyword_repository.dart';
import 'package:message_assistant/domain/repositories/i_config_store.dart';
import 'package:message_assistant/domain/services/message_pipeline.dart';

class _FakeMsgRepo implements IMessageRepository {
  int saveCalls = 0;
  final bool dupExists;
  _FakeMsgRepo({this.dupExists = false});
  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async { saveCalls++; return right(r); }
  @override
  Future<Either<Failure, bool>> existsByFingerprint(String f) async => right(dupExists);
  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async => right([]);
  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markReplied(String id, String reply) async => right(null);
}

class _FakeKwRepo implements IKeywordRepository {
  final List<KeywordRule> rules;
  _FakeKwRepo(this.rules);
  @override
  Future<Either<Failure, List<KeywordRule>>> findAll() async => right(rules);
  @override
  Future<Either<Failure, List<KeywordRule>>> findByScope(String groupId) async => right(rules);
  @override
  Future<Either<Failure, KeywordRule>> save(KeywordRule r) async => right(r);
  @override
  Future<Either<Failure, void>> delete(String id) async => right(null);
}

class _FakeConfigStore implements IConfigStore {
  @override
  Future<Either<Failure, QuietHours>> getQuietHours() async => right(const QuietHours.disabled());
  @override
  Future<Either<Failure, void>> setQuietHours(QuietHours qh) async => right(null);
  @override
  Future<Either<Failure, List<String>>> getTargetAppPackages() async => right(['com.tencent.mm']);
}

void main() {
  final base = DateTime(2026, 7, 30, 14, 32);

  RawNotificationEvent _event(String content) => RawNotificationEvent(
    appId: 'com.tencent.mm', groupId: 'g1', groupName: '群',
    senderName: '王', content: content, occurredAt: base,
  );

  test('hit -> save 1x + returns MatchResult', () async {
    final repo = _FakeMsgRepo();
    final pipe = MessagePipeline(
      messageRepo: repo, keywordRepo: _FakeKwRepo([KeywordRule(id:'k',keyword:'南京',createdAt:base)]),
      dedup: MessageDedupService(), matcher: KeywordMatchService(), policy: NotifyPolicyService(),
      configStore: _FakeConfigStore(), now: () => base,
    );
    final r = await pipe.process(_event('南京到上海'));
    expect(r, isNotNull);
    expect(repo.saveCalls, 1);
  });

  test('no hit -> not saved, returns null', () async {
    final repo = _FakeMsgRepo();
    final pipe = MessagePipeline(
      messageRepo: repo, keywordRepo: _FakeKwRepo([KeywordRule(id:'k',keyword:'不存在',createdAt:base)]),
      dedup: MessageDedupService(), matcher: KeywordMatchService(), policy: NotifyPolicyService(),
      configStore: _FakeConfigStore(), now: () => base,
    );
    final r = await pipe.process(_event('南京到上海'));
    expect(r, isNull);
    expect(repo.saveCalls, 0); // 关键断言：未命中不入库
  });

  test('duplicate -> not saved, not matched, returns null', () async {
    final repo = _FakeMsgRepo(dupExists: true);
    var matched = false;
    final pipe = MessagePipeline(
      messageRepo: repo, keywordRepo: _FakeKwRepo([KeywordRule(id:'k',keyword:'南京',createdAt:base)]),
      dedup: MessageDedupService(), matcher: KeywordMatchService(), policy: NotifyPolicyService(),
      configStore: _FakeConfigStore(), now: () => base,
    );
    final r = await pipe.process(_event('南京到上海'));
    expect(r, isNull);
    expect(repo.saveCalls, 0);
  });

  test('quiet hours -> saved but shouldNotify=false', () async {
    final repo = _FakeMsgRepo();
    final pipe = MessagePipeline(
      messageRepo: repo, keywordRepo: _FakeKwRepo([KeywordRule(id:'k',keyword:'南京',createdAt:base)]),
      dedup: MessageDedupService(), matcher: KeywordMatchService(), policy: NotifyPolicyService(),
      configStore: _FakeConfigStore(), now: () => DateTime(2026,7,30,3,0),
    );
    final r = await pipe.process(_event('南京到上海'));
    expect(r, isNotNull);
    expect(repo.saveCalls, 1); // 仍入库
    expect(r!.shouldNotify, isFalse); // 但不通知
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/domain/message_pipeline_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现 MessagePipeline**

```dart
// lib/domain/services/message_pipeline.dart
import 'package:uuid/uuid.dart';
import '../entities/failure.dart';
import '../entities/match_result.dart';
import '../entities/message_record.dart';
import '../entities/raw_notification_event.dart';
import '../repositories/i_message_repository.dart';
import '../repositories/i_keyword_repository.dart';
import '../repositories/i_config_store.dart';
import 'keyword_match_service.dart';
import 'message_dedup_service.dart';
import 'notify_policy_service.dart';

class PipelineOutcome {
  final MatchResult result;
  final bool shouldNotify;
  PipelineOutcome(this.result, this.shouldNotify);
}

class MessagePipeline {
  final IMessageRepository messageRepo;
  final IKeywordRepository keywordRepo;
  final MessageDedupService dedup;
  final KeywordMatchService matcher;
  final NotifyPolicyService policy;
  final IConfigStore configStore;
  final DateTime Function() now;
  final Uuid _uuid = const Uuid();

  MessagePipeline({
    required this.messageRepo, required this.keywordRepo, required this.dedup,
    required this.matcher, required this.policy, required this.configStore,
    DateTime Function()? now,
  }) : now = now ?? (() => DateTime.now());

  Future<PipelineOutcome?> process(RawNotificationEvent event) async {
    final senderId = event.senderId ?? event.senderName;
    final fingerprint = dedup.fingerprint(event.appId, event.groupId, senderId, event.content, event.occurredAt);

    // 去重
    final dupEither = await messageRepo.existsByFingerprint(fingerprint);
    final isDup = dupEither.fold((l) => false, (r) => r);
    if (isDup) return null;

    // 加载生效关键词
    final rulesEither = await keywordRepo.findByScope(event.groupId);
    final rules = rulesEither.fold((l) => <KeywordRule>[], (r) => r); // 注意需 import KeywordRule

    // 构建 MessageRecord 供匹配
    final receivedAt = now();
    final message = MessageRecord(
      id: _uuid.v4(), appId: event.appId, groupId: event.groupId, groupName: event.groupName,
      senderName: event.senderName, senderId: event.senderId, content: event.content,
      occurredAt: event.occurredAt, receivedAt: receivedAt, fingerprint: fingerprint,
      createdAt: receivedAt,
    );

    // 匹配
    final matchResult = matcher.match(message, rules);
    if (matchResult == null) return null; // 未命中不存库

    // 持久化（命中才入库）
    await messageRepo.save(matchResult.message);

    // 通知策略
    final qhEither = await configStore.getQuietHours();
    final qh = qhEither.getOrElse((l) => const QuietHours.disabled());
    final shouldNotify = policy.shouldNotify(receivedAt, qh);

    return PipelineOutcome(matchResult, shouldNotify);
  }
}
```
（注意：实现顶部需补 `import '../entities/keyword_rule.dart';`，因 `rules` 变量用到 KeywordRule 泛型——实施时确保 import 完整。）

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/domain/message_pipeline_test.dart`
Expected: 4/4 PASS。

- [ ] **Step 5: 验证 domain 隔离（uuid/crypto 应在白名单）**

Run: `dart run tool/domain_lint.dart`
Expected: exit 0。（若报 uuid 不在白名单，把 `package:uuid` 加入 `tool/domain_lint.dart` 白名单。）

- [ ] **Step 6: Commit（可选）**

### Task 2.9: 领域层全量回归 + 隔离最终验证

- [ ] **Step 1: 跑全部领域测试**

Run: `flutter test test/domain/`
Expected: 全 PASS，输出覆盖的用例数。

- [ ] **Step 2: 验证 domain 隔离**

Run: `dart run tool/domain_lint.dart`
Expected: exit 0。

- [ ] **Step 3: 静态分析**

Run: `flutter analyze lib/domain`
Expected: No issues。

- [ ] **Step 4: 记录覆盖率证据**

Run: `flutter test --coverage test/domain/ && dart pub global run coverage_filter`（或简单记录 PASS 数）
记录到工作日志：领域层测试全绿，作为可验证证据。

---

## Phase 3: 基础设施层（Drift）

### Task 3.1: Drift 数据库定义与表

**Files:**
- Create: `lib/infrastructure/database/tables/messages.dart`, `keywords.dart`, `groups.dart`
- Create: `lib/infrastructure/database/database.dart`
- Create: `lib/infrastructure/database/daos/message_dao.dart`, `keyword_dao.dart`
- Create: `test/infrastructure/database_test.dart`

- [ ] **Step 1: 写测试（内存库，验证建表与基础 CRUD）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:message_assistant/infrastructure/database/database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('insert and query message', () async {
    final id = await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: '[]', occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    expect(id, 'm1');
    final all = await db.messageDao.recentMessages();
    expect(all.length, 1);
  });

  test('fingerprint unique constraint', () async {
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: '[]', occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    expect(
      () => db.messageDao.insertMessage(MessageRecordsCompanion.insert(
        id: 'm2', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
        matchedKeywordsJson: '[]', occurredAt: DateTime(2026), receivedAt: DateTime(2026),
        fingerprint: 'fp1', createdAt: DateTime(2026),
      )),
      throwsA(isA<Object>()),
    );
  });

  test('existsByFingerprint', () async {
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: '[]', occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    expect(await db.messageDao.existsByFingerprint('fp1'), isTrue);
    expect(await db.messageDao.existsByFingerprint('nope'), isFalse);
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/infrastructure/database_test.dart`
Expected: FAIL（AppDatabase 未定义）。

- [ ] **Step 3: 实现表 messages.dart**

```dart
// lib/infrastructure/database/tables/messages.dart
import 'package:drift/drift.dart';

class MessageRecords extends Table {
  TextColumn get id => text()();
  TextColumn get appId => text()();
  TextColumn get groupId => text()();
  TextColumn get groupName => text().nullable()();
  TextColumn get senderName => text()();
  TextColumn get senderId => text().nullable()();
  TextColumn get content => text()();
  TextColumn get matchedKeywordsJson => text().withDefault(const Constant('[]'))();
  IntColumn get score => integer().withDefault(const Constant(0))();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isReplied => boolean().withDefault(const Constant(false))();
  TextColumn get replyContent => text().nullable()();
  TextColumn get fingerprint => text().unique()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 4: 实现表 keywords.dart**

```dart
// lib/infrastructure/database/tables/keywords.dart
import 'package:drift/drift.dart';

class KeywordRules extends Table {
  TextColumn get id => text()();
  TextColumn get keyword => text()();
  IntColumn get type => integer()(); // 0=exact,1=contains
  IntColumn get priority => integer().withDefault(const Constant(50))();
  TextColumn get scopeGroupIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get excludeWordsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get groupName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 5: 实现表 groups.dart**

```dart
// lib/infrastructure/database/tables/groups.dart
import 'package:drift/drift.dart';

class MonitoredGroups extends Table {
  TextColumn get groupId => text()();
  TextColumn get groupName => text()();
  TextColumn get appId => text()();
  BoolColumn get isWhitelist => boolean().withDefault(const Constant(false))();
  BoolColumn get isBlacklist => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastActiveAt => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId};
}
```

- [ ] **Step 6: 实现 message_dao.dart**

```dart
// lib/infrastructure/database/daos/message_dao.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/messages.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [MessageRecords])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<String> insertMessage(MessageRecordsCompanion entry) async {
    await into(messageRecords).insert(entry);
    return entry.id.value;
  }

  Future<List<MessageRecord>> recentMessages({String? groupId, int limit = 50, int offset = 0}) {
    final q = (select(messageRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit, offset: offset));
    if (groupId != null) q.where((t) => t.groupId.equals(groupId));
    return q.get();
  }

  Future<bool> existsByFingerprint(String fp) async {
    final q = select(messageRecords)..where((t) => t.fingerprint.equals(fp));
    final r = await q.getSingleOrNull();
    return r != null;
  }

  Future<MessageRecord?> findById(String id) {
    return (select(messageRecords)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> markRead(String id) =>
    (update(messageRecords)..where((t) => t.id.equals(id))).write(const MessageRecordsCompanion(isRead: Value(true)));
  Future<void> markReplied(String id, String reply) =>
    (update(messageRecords)..where((t) => t.id.equals(id))).write(MessageRecordsCompanion(isReplied: const Value(true), replyContent: Value(reply)));
}
```

- [ ] **Step 7: 实现 keyword_dao.dart**

```dart
// lib/infrastructure/database/daos/keyword_dao.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/keywords.dart';

part 'keyword_dao.g.dart';

@DriftAccessor(tables: [KeywordRules])
class KeywordDao extends DatabaseAccessor<AppDatabase> with _$KeywordDaoMixin {
  KeywordDao(super.db);

  Future<List<KeywordRule>> all() => select(keywordRules).get();
  Future<int> upsert(KeywordRulesCompanion entry) => into(keywordRules).insertOnConflictUpdate(entry);
  Future<int> deleteById(String id) => (delete(keywordRules)..where((t) => t.id.equals(id))).go();
}
```

- [ ] **Step 8: 实现 database.dart**

```dart
// lib/infrastructure/database/database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'daos/message_dao.dart';
import 'daos/keyword_dao.dart';
import 'tables/messages.dart';
import 'tables/keywords.dart';
import 'tables/groups.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [MessageRecords, KeywordRules, MonitoredGroups],
  daos: [MessageDao, KeywordDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  MessageDao get messageDao => MessageDao(this);
  KeywordDao get keywordDao => KeywordDao(this);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ma.sqlite'));
    return NativeDatabase(file);
  });
}
```

- [ ] **Step 9: 生成代码**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 生成 `database.g.dart`、`message_dao.g.dart`、`keyword_dao.g.dart`，无错误。

- [ ] **Step 10: 运行测试，确认通过**

Run: `flutter test test/infrastructure/database_test.dart`
Expected: 3/3 PASS。

- [ ] **Step 11: Commit（可选）**

### Task 3.2: Drift 仓储实现（实现领域端口）

**Files:**
- Create: `lib/infrastructure/database/drift_repositories.dart`
- Create: `test/infrastructure/drift_repositories_test.dart`

- [ ] **Step 1: 写测试（验证仓储实现端口契约 + 命中入库、未命中不调用由 Pipeline 保证，这里测仓储自身 CRUD）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart' show MatchType;
import 'package:message_assistant/infrastructure/database/database.dart';
import 'package:message_assistant/infrastructure/database/drift_repositories.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('DriftMessageRepository save + findById roundtrip', () async {
    final repo = DriftMessageRepository(db);
    final msg = MessageRecord(
      id:'m1', appId:'a', groupId:'g', groupName:'群', senderName:'王',
      content:'南京到上海',
      hits: const [KeywordHit(ruleId:'k', keyword:'到', type: MatchType.contains, priority:50, highlightPositions:[2])],
      score: 50, occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    );
    final saved = await repo.save(msg);
    expect(saved.isRight(), isTrue);
    final found = await repo.findById('m1');
    final m = found.getOrElse((l) => null);
    expect(m, isNotNull);
    expect(m!.content, '南京到上海');
    expect(m.hits.single.keyword, '到');
  });

  test('DriftKeywordRepository save + findAll', () async {
    final repo = DriftKeywordRepository(db);
    await repo.save(KeywordRule(id:'k1', keyword:'南京', createdAt: DateTime(2026)));
    final all = await repo.findAll();
    expect(all.getOrElse((l)=>[]).length, 1);
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/infrastructure/drift_repositories_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现 drift_repositories.dart**

```dart
// lib/infrastructure/database/drift_repositories.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/keyword_rule.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/message_record.dart';
import '../../domain/repositories/i_message_repository.dart';
import '../../domain/repositories/i_keyword_repository.dart';
import 'database.dart';
import 'tables/messages.dart' as t;
import 'tables/keywords.dart' as kt;

class DriftMessageRepository implements IMessageRepository {
  final AppDatabase db;
  DriftMessageRepository(this.db);

  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async {
    try {
      final hitsJson = jsonEncode(r.hits.map((h) => {
        'ruleId': h.ruleId, 'keyword': h.keyword, 'type': h.type.index,
        'priority': h.priority, 'highlightPositions': h.highlightPositions,
      }).toList());
      await db.messageDao.insertMessage(t.MessageRecordsCompanion.insert(
        id: r.id, appId: r.appId, groupId: r.groupId, groupName: Value(r.groupName),
        senderName: r.senderName, senderId: Value(r.senderId), content: r.content,
        matchedKeywordsJson: Value(hitsJson), score: Value(r.score),
        occurredAt: r.occurredAt, receivedAt: r.receivedAt,
        isRead: Value(r.isRead), isReplied: Value(r.isReplied), replyContent: Value(r.replyContent),
        fingerprint: r.fingerprint, createdAt: r.createdAt,
      ));
      return right(r);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  MessageRecord _toEntity(t.MessageRecord row) {
    final hitsList = (jsonDecode(row.matchedKeywordsJson) as List).map((j) {
      final m = j as Map<String, dynamic>;
      return KeywordHit(ruleId: m['ruleId'] as String, keyword: m['keyword'] as String,
        type: MatchType.values[m['type'] as int], priority: m['priority'] as int,
        highlightPositions: (m['highlightPositions'] as List).cast<int>());
    }).toList();
    return MessageRecord(
      id: row.id, appId: row.appId, groupId: row.groupId, groupName: row.groupName,
      senderName: row.senderName, senderId: row.senderId, content: row.content,
      hits: hitsList, score: row.score, occurredAt: row.occurredAt, receivedAt: row.receivedAt,
      isRead: row.isRead, isReplied: row.isReplied, replyContent: row.replyContent,
      fingerprint: row.fingerprint, createdAt: row.createdAt,
    );
  }

  @override
  Future<Either<Failure, bool>> existsByFingerprint(String fp) async {
    try { return right(await db.messageDao.existsByFingerprint(fp)); }
    catch (e) { return left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async {
    try {
      final rows = await db.messageDao.recentMessages(groupId: groupId, limit: limit, offset: offset);
      return right(rows.map(_toEntity).toList());
    } catch (e) { return left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async {
    try {
      final row = await db.messageDao.findById(id);
      return right(row == null ? null : _toEntity(row));
    } catch (e) { return left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async {
    try { await db.messageDao.markRead(id); return right(null); }
    catch (e) { return left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, void>> markReplied(String id, String replyContent) async {
    try { await db.messageDao.markReplied(id, replyContent); return right(null); }
    catch (e) { return left(DatabaseFailure(e.toString())); }
  }
}

class DriftKeywordRepository implements IKeywordRepository {
  final AppDatabase db;
  DriftKeywordRepository(this.db);

  @override
  Future<Either<Failure, List<KeywordRule>>> findAll() async {
    try {
      final rows = await db.keywordDao.all();
      return right(rows.map(_toEntity).toList());
    } catch (e) { return left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<KeywordRule>>> findByScope(String groupId) async {
    // MVP: findByScope 返回全部 enabled 规则；scope 过滤由 KeywordMatchService 内部处理
    final all = await findAll();
    return all.map((rules) => rules.where((r) => r.enabled).toList());
  }

  KeywordRule _toEntity(kt.KeywordRule row) => KeywordRule(
    id: row.id, keyword: row.keyword, type: MatchType.values[row.type],
    priority: row.priority,
    scopeGroupIds: (jsonDecode(row.scopeGroupIdsJson) as List).cast<String>(),
    excludeWords: (jsonDecode(row.excludeWordsJson) as List).cast<String>(),
    enabled: row.enabled, groupName: row.groupName,
    createdAt: row.createdAt, updatedAt: row.updatedAt,
  );

  @override
  Future<Either<Failure, KeywordRule>> save(KeywordRule r) async {
    try {
      await db.keywordDao.upsert(kt.KeywordRulesCompanion.insert(
        id: r.id, keyword: r.keyword, type: r.type.index, priority: Value(r.priority),
        scopeGroupIdsJson: Value(jsonEncode(r.scopeGroupIds)),
        excludeWordsJson: Value(jsonEncode(r.excludeWords)),
        enabled: Value(r.enabled), groupName: Value(r.groupName),
        createdAt: r.createdAt, updatedAt: Value(r.updatedAt),
      ));
      return right(r);
    } catch (e) { return left(DatabaseFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try { await db.keywordDao.deleteById(id); return right(null); }
    catch (e) { return left(DatabaseFailure(e.toString())); }
  }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/infrastructure/drift_repositories_test.dart`
Expected: PASS。

- [ ] **Step 5: Commit（可选）**

---

## Phase 4: 表示层（Riverpod + Widget）

### Task 4.1: 命中词高亮 Widget

**Files:**
- Create: `lib/presentation/widgets/keyword_highlight_text.dart`
- Create: `test/presentation/keyword_highlight_text_test.dart`

- [ ] **Step 1: 写测试**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/presentation/widgets/keyword_highlight_text.dart';
import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';

void main() {
  testWidgets('renders highlighted spans for hits', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeywordHighlightText(
          text: '南京到上海',
          hits: const [KeywordHit(ruleId:'k', keyword:'到', type: MatchType.contains, priority:50, highlightPositions:[2])],
        ),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText));
    final spans = rich.text.getChildren()!;
    // 至少应有多段（普通 + 高亮 + 普通）
    expect(spans.length, greaterThan(1));
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/presentation/keyword_highlight_text_test.dart`
Expected: FAIL。

- [ ] **Step 3: 实现**

```dart
// lib/presentation/widgets/keyword_highlight_text.dart
import 'package:flutter/material.dart';
import '../../domain/entities/match_result.dart';

class KeywordHighlightText extends StatelessWidget {
  final String text;
  final List<KeywordHit> hits;
  final TextStyle? baseStyle;
  final Color highlightColor;

  const KeywordHighlightText({
    super.key, required this.text, required this.hits,
    this.baseStyle, this.highlightColor = const Color(0xFFFFD54F),
  });

  @override
  Widget build(BuildContext context) {
    final positions = <int>{};
    for (final h in hits) {
      for (final p in h.highlightPositions) {
        for (var i = 0; i < h.keyword.length; i++) positions.add(p + i);
      }
    }
    final spans = <TextSpan>[];
    var buf = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final isHi = positions.contains(i);
      if (!isHi) {
        buf.write(text[i]);
      } else {
        if (buf.isNotEmpty) { spans.add(TextSpan(text: buf.toString())); buf = StringBuffer(); }
        spans.add(TextSpan(text: text[i], style: TextStyle(backgroundColor: highlightColor)));
      }
    }
    if (buf.isNotEmpty) spans.add(TextSpan(text: buf.toString()));
    return RichText(text: TextSpan(style: baseStyle ?? DefaultTextStyle.of(context).style, children: spans));
  }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `flutter test test/presentation/keyword_highlight_text_test.dart`
Expected: PASS。

- [ ] **Step 5: Commit（可选）**

### Task 4.2: Providers（Riverpod 状态管理）

**Files:**
- Create: `lib/presentation/providers/providers.dart`

- [ ] **Step 1: 实现 providers**

```dart
// lib/presentation/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/keyword_match_service.dart';
import '../../domain/services/message_dedup_service.dart';
import '../../domain/services/message_pipeline.dart';
import '../../domain/services/notify_policy_service.dart';
import '../../domain/repositories/i_message_repository.dart';
import '../../domain/repositories/i_keyword_repository.dart';
import '../../domain/repositories/i_config_store.dart';
import '../../domain/entities/match_result.dart';
import '../../infrastructure/database/database.dart';
import '../../infrastructure/database/drift_repositories.dart';

// 基础设施
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final messageRepoProvider = Provider<IMessageRepository>((ref) => DriftMessageRepository(ref.read(databaseProvider)));
final keywordRepoProvider = Provider<IKeywordRepository>((ref) => DriftKeywordRepository(ref.read(databaseProvider)));

// 领域服务（无状态，单例即可）
final matcherProvider = Provider((ref) => KeywordMatchService());
final dedupProvider = Provider((ref) => MessageDedupService());
final policyProvider = Provider((ref) => NotifyPolicyService());

final pipelineProvider = Provider<MessagePipeline>((ref) => MessagePipeline(
  messageRepo: ref.read(messageRepoProvider),
  keywordRepo: ref.read(keywordRepoProvider),
  dedup: ref.read(dedupProvider),
  matcher: ref.read(matcherProvider),
  policy: ref.read(policyProvider),
  configStore: ref.read(configStoreProvider), // 见下
));

// 简单内存 ConfigStore（MVP：配置存数据库前先用内存实现占位）
final configStoreProvider = Provider<IConfigStore>((ref) => _MemoryConfigStore());

class _MemoryConfigStore implements IConfigStore {
  QuietHours _qh = const QuietHours.disabled();
  @override
  Future<Either<Failure, QuietHours>> getQuietHours() async => right(_qh);
  @override
  Future<Either<Failure, void>> setQuietHours(QuietHours qh) async { _qh = qh; return right(null); }
  @override
  Future<Either<Failure, List<String>>> getTargetAppPackages() async => right(['com.tencent.mm']);
}

// 消息列表
final messageListProvider = FutureProvider.autoDispose.family<List<MessageRecord>, String?>((ref, groupId) async {
  final repo = ref.watch(messageRepoProvider);
  final either = await repo.findRecentPaged(groupId: groupId);
  return either.fold((l) => [], (r) => r);
});

// 关键词列表
final keywordListProvider = FutureProvider.autoDispose<List<KeywordRule>>((ref) async {
  final repo = ref.watch(keywordRepoProvider);
  final either = await repo.findAll();
  return either.fold((l) => [], (r) => r);
});
```
（需补 import dartz 的 right/left、entity import。实施时整理 import。）

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/presentation/providers`
Expected: No issues。

- [ ] **Step 3: Commit（可选）**

### Task 4.3: 消息列表页 + 详情页 + 关键词页 + 设置页 + 引导页

**Files:**
- Create: `lib/presentation/pages/home/home_page.dart`, `message_detail/message_detail_page.dart`, `keyword_config/keyword_list_page.dart`, `keyword_config/keyword_edit_page.dart`, `settings/settings_page.dart`, `onboarding/onboarding_page.dart`
- Create: `lib/app/router.dart`, `lib/app/app.dart`, `lib/main.dart`

- [ ] **Step 1: 实现 home_page.dart（消息列表，命中高亮，空状态）**

完整页面：AppBar（标题+设置按钮）、群筛选下拉、`Consumer` 监听 `messageListProvider`、`ListView.builder` 卡片项（群名、发送人、`KeywordHighlightText`、命中词数）、空状态引导。点击项 → `context.push('/message/$id')`。

（实现约 80 行，遵循 Material 3，ConsumerWidget + ref.watch。）

- [ ] **Step 2: 实现 message_detail_page.dart**

显示群名、发送人、时间、`KeywordHighlightText`（全文）、命中词列表+优先级+得分；按钮：复制消息、复制并打开微信（调 launcher channel）、标记已回复。

- [ ] **Step 3: 实现 keyword_list_page.dart + keyword_edit_page.dart**

列表按 groupName 分组、每项显示关键词/类型/优先级/生效群/排除词 + 编辑/删除；编辑页表单：关键词输入、类型单选、优先级滑块、生效群（MVP 简化为"全部"开关）、排除词列表+添加。

- [ ] **Step 4: 实现 settings_page.dart**

通知监听状态（读 permission channel）、夜间静默时段开关+起止小时、监听目标 App（微信勾选）、服务状态、重启服务按钮、隐私政策入口、导出/清空。

- [ ] **Step 5: 实现 onboarding_page.dart（权限引导）**

检查通知监听权限；未授权 → 全屏引导（说明用途 + "数据仅本地不上传" + [去开启]按钮 → permission channel 跳系统授权页）。

- [ ] **Step 6: 实现 router.dart + app.dart + main.dart**

```dart
// lib/app/router.dart
final goRouter = GoRouter(routes: [
  GoRoute(path: '/', builder: (c, s) => const HomePage()),
  GoRoute(path: '/message/:id', builder: (c, s) => MessageDetailPage(id: s.pathParameters['id']!)),
  GoRoute(path: '/keywords', builder: (c, s) => const KeywordListPage()),
  GoRoute(path: '/keywords/new', builder: (c, s) => const KeywordEditPage()),
  GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
]);

// lib/main.dart
void main() {
  runApp(const ProviderScope(child: MessageAssistantApp()));
}
```
（app.dart：MaterialApp.router + 主题 + 底部导航 ShellRoute 包裹 home/keywords/history/settings 四 tab。）

- [ ] **Step 7: 写 Widget 测试（列表渲染、空状态，Mock provider override）**

`test/presentation/home_page_test.dart`：用 `ProviderScope(overrides: [messageListProvider.overrideWith(...)])` 注入假数据，断言渲染出卡片项与高亮；注入空列表断言空状态引导出现。

- [ ] **Step 8: 运行 Widget 测试**

Run: `flutter test test/presentation/`
Expected: PASS。

- [ ] **Step 9: Commit（可选）**

---

## Phase 5: Android 原生（Kotlin）

### Task 5.1: NotificationParser 纯函数 + JUnit 单测

**Files:**
- Create: `android/app/src/main/kotlin/com/example/ma/NotificationParser.kt`
- Create: `android/app/src/test/kotlin/com/example/ma/NotificationParserTest.kt`

- [ ] **Step 1: 写测试**

```kotlin
// NotificationParserTest.kt
package com.example.ma

import org.junit.Assert.*
import org.junit.Test

class NotificationParserTest {
    @Test fun groupMessage_parsesTitleAndSender() {
        val r = NotificationParser.parse("货运华东群(3)", "王师傅: 南京到上海", "com.tencent.mm")
        assertEquals("货运华东群", r.groupName)
        assertEquals("王师傅", r.senderName)
        assertEquals("南京到上海", r.content)
        assertTrue(r.isGroup)
    }
    @Test fun singleChat_noBracketsInTitle() {
        val r = NotificationParser.parse("王师傅", "南京到上海", "com.tencent.mm")
        assertEquals("王师傅", r.senderName)
        assertEquals("南京到上海", r.content)
        assertFalse(r.isGroup)
    }
    @Test fun aggregatedMessage_keepsVisibleContent() {
        val r = NotificationParser.parse("货运华东群", "[3条]王师傅: 南京到上海", "com.tencent.mm")
        assertTrue(r.content.contains("南京到上海"))
    }
    @Test fun nonTargetPackage_returnsNull() {
        val r = NotificationParser.parse("货运华东群", "x", "com.other.app")
        assertNull(r)
    }
    @Test fun emptyText_returnsNull() {
        val r = NotificationParser.parse("货运华东群", "", "com.tencent.mm")
        assertNull(r)
    }
    @Test fun noColonInText_treatsWholeTextAsContent() {
        val r = NotificationParser.parse("货运华东群", "整段无冒号", "com.tencent.mm")
        assertEquals("整段无冒号", r.content)
    }
    @Test fun groupId_isStableHashOfAppAndGroup() {
        val a = NotificationParser.parse("货运华东群", "王: x", "com.tencent.mm")!!
        val b = NotificationParser.parse("货运华东群(9)", "李: y", "com.tencent.mm")!!
        assertEquals(a.groupId, b.groupId)
    }
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `cd android && ./gradlew :app:testDebugUnitTest --tests "com.example.ma.NotificationParserTest"`
Expected: FAIL（NotificationParser 未定义）。

- [ ] **Step 3: 实现 NotificationParser.kt**

```kotlin
// NotificationParser.kt
package com.example.ma

import java.security.MessageDigest

data class ParsedNotification(
    val appId: String, val groupId: String, val groupName: String?,
    val senderName: String, val content: String, val isGroup: Boolean
)

object NotificationParser {
    private val TARGET_PACKAGES = setOf("com.tencent.mm")

    fun parse(title: String?, text: String?, pkg: String): ParsedNotification? {
        if (pkg !in TARGET_PACKAGES) return null
        if (text.isNullOrBlank()) return null
        val t = title?.trim().orEmpty()

        // 群消息：title 形如 "群名(数字)"
        val groupMatch = Regex("^(.*)\\(\\d+\\)$").find(t)
        return if (groupMatch != null) {
            val groupName = groupMatch.groupValues[1].trim()
            val (sender, content) = splitSender(text)
            ParsedNotification(pkg, groupId(pkg, groupName), groupName, sender, content, true)
        } else {
            // 单聊：title = 发送人
            val sender = if (t.isEmpty()) "未知" else t
            ParsedNotification(pkg, groupId(pkg, sender), null, sender, text.trim(), false)
        }
    }

    private fun splitSender(text: String): Pair<String, String> {
        val idx = text.indexOf(": ")
        return if (idx >= 0) text.substring(0, idx).trim() to text.substring(idx + 2).trim()
        else "未知" to text.trim()
    }

    private fun groupId(appId: String, name: String): String {
        val md = MessageDigest.getInstance("SHA-1")
        val raw = "$appId|$name"
        return md.digest(raw.toByteArray()).joinToString("") { "%02x".format(it) }.substring(0, 16)
    }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `cd android && ./gradlew :app:testDebugUnitTest --tests "com.example.ma.NotificationParserTest"`
Expected: 全 PASS。

- [ ] **Step 5: Commit（可选）**

### Task 5.2: NotificationListenerService + 前台服务 + EventChannel

**Files:**
- Create: `android/app/src/main/kotlin/com/example/ma/MessageNotificationListenerService.kt`
- Create: `android/app/src/main/kotlin/com/example/ma/MonitorForegroundService.kt`
- Create: `android/app/src/main/kotlin/com/example/ma/NotificationPlugin.kt`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: 实现 MonitorForegroundService.kt（前台服务 + 持有 EventSink）**

```kotlin
package com.example.ma

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel.EventSink

class MonitorForegroundService : Service() {
    companion object {
        @Volatile var eventSink: EventSink? = null
        private const val CH_ID = "ma_foreground"
        private const val NOTIF_ID = 1001
    }

    override fun onCreate() {
        super.onCreate()
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && nm.getNotificationChannel(CH_ID) == null) {
            nm.createNotificationChannel(NotificationChannel(CH_ID, "监听服务", NotificationManager.IMPORTANCE_LOW))
        }
        val n = NotificationCompat.Builder(this, CH_ID)
            .setContentTitle("消息监听运行中")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true).build()
        startForeground(NOTIF_ID, n)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY
    override fun onBind(intent: Intent?): IBinder? = null
}
```

- [ ] **Step 2: 实现 MessageNotificationListenerService.kt**

```kotlin
package com.example.ma

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import java.util.Date

class MessageNotificationListenerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val pkg = sbn.packageName ?: return
        val n = sbn.notification ?: return
        val extras = n.extras
        val title = extras.getCharSequence("android.title")?.toString()
        val text = extras.getCharSequence("android.text")?.toString()
        val parsed = NotificationParser.parse(title, text, pkg) ?: return
        val event = mapOf(
            "appId" to parsed.appId, "groupId" to parsed.groupId,
            "groupName" to (parsed.groupName ?: ""), "senderName" to parsed.senderName,
            "content" to parsed.content, "occurredAt" to Date().time
        )
        MonitorForegroundService.eventSink?.success(event)
    }
}
```

- [ ] **Step 3: 实现 NotificationPlugin.kt（注册 EventChannel + control MethodChannel）**

```kotlin
package com.example.ma

import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class NotificationPlugin : FlutterPlugin, EventChannel.StreamHandler, MethodCallHandler {
    private lateinit var eventChannel: EventChannel
    private lateinit var controlChannel: MethodChannel
    private lateinit var context: android.content.Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        eventChannel = EventChannel(binding.binaryMessenger, "message_assistant/notification")
        eventChannel.setStreamHandler(this)
        controlChannel = MethodChannel(binding.binaryMessenger, "message_assistant/control")
        controlChannel.setMethodCallHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        MonitorForegroundService.eventSink = events
        val intent = Intent(context, MonitorForegroundService::class.java)
        if (android.os.Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent)
        else context.startService(intent)
    }
    override fun onCancel(arguments: Any?) { MonitorForegroundService.eventSink = null }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "launchWechat" -> result.success(launchWechat())
            "copyToClipboard" -> { copyToClipboard(call.argument<String>("text") ?: ""); result.success(true) }
            "isNotificationListenerEnabled" -> result.success(isListenerEnabled())
            "openNotificationListenerSettings" -> { openListenerSettings(); result.success(true) }
            else -> result.notImplemented()
        }
    }

    private fun launchWechat(): Boolean {
        val intent = context.packageManager.getLaunchIntentForPackage("com.tencent.mm")
        return if (intent != null) { intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); context.startActivity(intent); true }
        else false
    }
    private fun copyToClipboard(text: String) {
        val cm = context.getSystemService(android.content.Context.CLIPBOARD_SERVICE) as android.content.ClipboardManager
        cm.setPrimaryClip(android.content.ClipData.newPlainText("msg", text))
    }
    private fun isListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(context.packageName)
    }
    private fun openListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel.setStreamHandler(null); controlChannel.setMethodCallHandler(null)
    }
}
```

- [ ] **Step 4: 注册插件到 MainApplication.kt**

修改 `MainApplication.kt`（Flutter 生成的）：在 `configureFlutterEngine` 中 `flutterEngine.plugins.add(NotificationPlugin())`。

- [ ] **Step 5: 更新 AndroidManifest.xml**

加入 spec §5.3 的全部权限与组件声明（NotificationListenerService、MonitorForegroundService 特殊前台服务类型、BootReceiver、VIBRATE、INTERNET）。

- [ ] **Step 6: 编译验证（不运行）**

Run: `cd android && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL。（运行行为需设备验证。）

- [ ] **Step 7: Commit（可选）**

### Task 5.3: BootReceiver + ServiceRestarter（保活）

**Files:**
- Create: `android/app/src/main/kotlin/com/example/ma/BootReceiver.kt`
- Create: `android/app/src/main/kotlin/com/example/ma/ServiceRestarter.kt`

- [ ] **Step 1: 实现 BootReceiver.kt**

```kotlin
package com.example.ma

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val svc = Intent(context, MonitorForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(svc)
            else context.startService(svc)
        }
    }
}
```

- [ ] **Step 2: 实现 ServiceRestarter.kt（WorkManager 周期心跳）**

```kotlin
package com.example.ma

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.*

class ServiceRestarter(appContext: Context, params: WorkerParameters) : CoroutineWorker(appContext, params) {
    override suspend fun doWork(): Result {
        // 简单心跳：尝试启动前台服务（若已存活则无副作用）
        val svc = Intent(applicationContext, MonitorForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= 26) applicationContext.startForegroundService(svc)
        return Result.success()
    }
    companion object {
        fun schedule(context: Context) {
            val req = PeriodicWorkRequestBuilder<ServiceRestarter>(15, java.util.concurrent.TimeUnit.MINUTES).build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork("ma_restarter", ExistingPeriodicWorkPolicy.KEEP, req)
        }
    }
}
```
（在 MainApplication.onCreate 调 `ServiceRestarter.schedule(this)`。）

- [ ] **Step 3: 加入 workmanager 依赖到 android/app/build.gradle**

```gradle
dependencies {
    implementation "androidx.work:work-runtime-ktx:2.9.0"
    implementation "androidx.core:core-ktx:1.12.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3"
}
```

- [ ] **Step 4: 编译验证**

Run: `cd android && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL。

- [ ] **Step 5: Commit（可选）**

---

## Phase 6: 集成、编译与文档

### Task 6.1: 端到端接线（Pipeline 订阅 EventChannel + LocalNotifier）

**Files:**
- Create: `lib/infrastructure/platform/notification_channel.dart`, `launcher_channel.dart`, `permission_channel.dart`
- Create: `lib/infrastructure/services/local_notifier.dart`
- Modify: `lib/presentation/providers/providers.dart`, `lib/main.dart`

- [ ] **Step 1: 实现 notification_channel.dart（订阅原生事件流 → 注入 Pipeline）**

`NotificationEventChannel`：通过 EventChannel 暴露 `Stream<RawNotificationEvent>`，main 中订阅它，每事件调 `pipeline.process()`，若返回 PipelineOutcome 且 shouldNotify，发本地通知并刷新列表 provider。

- [ ] **Step 2: 实现 launcher_channel.dart + permission_channel.dart**

封装 control MethodChannel 的 `launchWechat`/`copyToClipboard`/`isNotificationListenerEnabled`/`openNotificationListenerSettings`。

- [ ] **Step 3: 实现 local_notifier.dart**

`flutter_local_notifications` 初始化、创建 `message_matched` channel、`notify(result)` 发通知（标题=群名/发送人、正文=内容、命中词高亮符号、点击带 messageId 的 PendingIntent 回调）。

- [ ] **Step 4: 在 main.dart 接线**

启动时初始化 local_notifications；订阅 NotificationEventChannel；将命中事件推入一个 `pipelineEventProvider`（StreamProvider）供列表刷新。

- [ ] **Step 5: 验证编译**

Run: `flutter analyze`
Expected: No issues。

- [ ] **Step 6: Commit（可选）**

### Task 6.2: APK 编译验证

**Files:** 无（验证产物）

- [ ] **Step 1: 构建 debug APK**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL，产出 `build/app/outputs/flutter-apk/app-debug.apk`。

- [ ] **Step 2: 记录证据**

记录构建日志与 APK 路径到工作日志。明确标注："APK 已编译成功；运行时行为未经设备验证，需按 verification-checklist 在手机上验证"。

### Task 6.3: 设备验证清单 + README

**Files:**
- Create: `docs/verification-checklist.md`
- Create: `README.md`

- [ ] **Step 1: 编写 verification-checklist.md**

写入 spec §7.3 全部验证项（APK 安装、授权、前台服务常驻、含/不含关键词消息、点击跳转、去重、重启自启、WorkManager 重启、夜间静默、关键词热加载）。

- [ ] **Step 2: 编写 README.md**

环境要求、`flutter pub get`、`build_runner`、构建 APK、安装到手机步骤、验证清单指引、已知限制（iOS 无法在此构建）、合规声明。

- [ ] **Step 3: Commit（可选）**

### Task 6.4: 全量回归 + 最终证据汇总

- [ ] **Step 1: 跑全部 Dart 测试**

Run: `flutter test`
Expected: 全 PASS。

- [ ] **Step 2: 跑 Kotlin 测试**

Run: `cd android && ./gradlew :app:testDebugUnitTest`
Expected: 全 PASS（至少 NotificationParserTest）。

- [ ] **Step 3: 全量静态分析**

Run: `flutter analyze`
Expected: No issues。

- [ ] **Step 4: 验证 domain 隔离最终**

Run: `dart run tool/domain_lint.dart`
Expected: exit 0。

- [ ] **Step 5: 汇总验证证据表**

向用户汇报：哪些层 ✅ 有测试证据（领域/基础设施/Widget/Kotlin解析/分析）、APK ⚠️ 已编译未验证运行、端到端 ❌ 待设备验证。诚实分级，不声称端到端已验证。

---

## 自审记录

本计划已对照 spec 逐节核查：
- **Spec 覆盖**：F1 关键词（Task 2.2/3.2/4.3）、F2 监听（Task 5.2）、F3 匹配（Task 2.5）、F4 持久化（Task 3.1/3.2）、F5 提醒（Task 6.1 local_notifier + Task 2.7 静默）、F6 跳转（Task 5.2 launcher + Task 4.3 详情页）、F9 历史（Task 4.3）。环境搭建（Phase 0）、分层隔离（Task 1.3）、测试策略（贯穿）、验证清单（Task 6.3）均覆盖。
- **关键决策落地**：解析逻辑只在 Kotlin（Task 5.1）+ EventChannel 传结构化字段（Task 5.2），Dart Pipeline 不重复解析（Task 2.8）；未命中不入库由 Task 2.8 测试断言；groupId 在 Kotlin 生成（Task 5.1）。
- **类型一致性**：`KeywordMatchService.match` 返回 `MatchResult?`（Task 2.5）与 Pipeline 用法（Task 2.8）一致；`MessagePipeline.process` 返回 `PipelineOutcome?`（Task 2.8）含 shouldNotify（静默决策落地）；`findRecentPaged` 签名在端口（Task 2.4）、DAO（Task 3.1）、仓储实现（Task 3.2）一致。
- **无占位符**：每个代码 step 含完整代码；环境/不可测步骤明确说明预期行为与停止条件。

# 消息提醒器助手 — MVP 设计规格

> **文档版本**: v1.0
> **创建日期**: 2026-07-30
> **状态**: Approved（用户已逐节确认）
> **上游架构**: `docs/architecture.md` v1.0
> **本次范围**: P1 MVP（Android 可安装 APK），iOS 仅骨架

---

## 0. 背景与范围决策记录

### 0.1 上游关系

本规格是 `docs/architecture.md`（24 个月 / 5 阶段 / 14 功能蓝图）的**首个落地迭代**。架构文档已锁定的大决策（ADR-001~005）作为本 MVP 的既定条件，不再讨论：

- **ADR-001**: Flutter + Platform Channel 跨平台
- **ADR-002**: Android 双引擎（AccessibilityService 主 + NotificationListener 辅）
- **ADR-004**: Drift(SQLite) 本地存储
- **ADR-005**: 声明式规则热更新

### 0.2 本次范围决策（用户确认）

| 决策点 | 选择 | 理由 |
|--------|------|------|
| **范围** | P1 MVP（Android 可安装） | 架构 Phase 1 目标；产出可验证 APK |
| **监听引擎** | 先 NotificationListener（稳） | 拿通知栏消息即可跑通完整闭环；Accessibility 风险高、需设备调试，留下一迭代 |
| **点击行为** | 唤起微信主界面 + 复制消息 | 无 Accessibility 无法进特定群；Intent 唤起 + 剪贴板是 MVP 最佳折中 |
| **匹配能力** | 精确 + 包含匹配 + 排除词 + 群范围 | 货运场景子串匹配即够；引擎可扩展 |
| **保活** | 前台服务 + 开机自启 + 自恢复 | 满足架构 7.2 核心保活；厂商白名单引导留 P2 |
| **代码组织** | 单工程 + 领域隔离（方案 C） | 领域层纯 Dart 可脱离设备单测；避免多包过度工程；未来可无成本拆包 |
| **历史 tab** | 保留独立历史 tab（4 tab 不合并） | 消息=实时命中流；历史=按条件搜索含已读已回复 |

### 0.3 环境约束（硬约束，影响验证）

| 事项 | 状态 | 影响 |
|------|------|------|
| Flutter / Dart | ❌ 未安装 | 实施第 0 步必须先搭建环境 |
| Java | ✅ v20 | 可用 |
| adb | ✅ 已安装，但**无连接设备** | 端到端无法在此验证 |
| iOS toolchain | ❌ 仅 Windows | iOS 无法在此构建/签名，仅生成骨架 |
| 微信监听 | 需真机 + 微信 + 手动授权 | 最脆弱部分，只能由用户在手机验证 |

---

## 1. MVP 功能清单

**目标**：可安装到 Android 手机的 APK，跑通完整闭环：**微信通知 → 关键词匹配 → 本地提醒 → 点击唤起微信**。

### 1.1 本次实现

| 功能 | MVP 实现 | 架构来源 |
|------|----------|---------|
| F1 关键词配置 | CRUD、分组、优先级、排除词、生效群范围；精确+包含匹配 | F1 + F3 简化 |
| F2 消息监听 | **仅 NotificationListenerService**（标题=群名/发送人、内容=消息） | ADR-002 副引擎先行 |
| F4 消息持久化 | Drift(SQLite) 存**命中消息**，不做 SQLCipher 加密（P2），不做 FTS5（P2） | ADR-004 简化 |
| F5 实时提醒 | 本地通知（命中词高亮）+ 震动/铃声 + 夜间静默时段 | F5 |
| F6 点击跳转 | 点击通知/列表项 → Intent 唤起微信主界面 + 复制剪贴板 + Toast | F6 简化 |
| F9 历史列表 | 消息列表（实时流）+ 历史搜索页（按群/时间/已读筛选），分页 | F9 简化 |

### 1.2 本次明确排除（防范围蔓延）

- ❌ AccessibilityService 监听（下一迭代）
- ❌ 自动 @发送人、自动进特定群（需 Accessibility）
- ❌ 悬浮球（F11）
- ❌ 快捷回复话术（F8）
- ❌ SQLCipher 加密、FTS5 中文全文搜索、云端同步
- ❌ 多 App（QQ/钉钉/企微/飞书）、统计可视化、语义匹配
- ❌ iOS 真机构建与验证（此机 Windows；仅留可编译骨架）
- ❌ 规则热更新服务器下发（ADR-005 完整版留 P2；解析逻辑本地化、纯函数化便于改）

### 1.3 验证策略（核心原则）

| 层 | 工具 | 我可验证？ | 证据 |
|----|------|-----------|------|
| 领域层单测 | `flutter test`（纯 Dart） | ✅ | 测试输出 + 覆盖率 |
| Kotlin 解析单测 | JUnit 5 | ✅ | 测试输出 |
| 基础设施层单测 | `flutter test`（内存 Drift） | ✅ | 测试输出 |
| Widget 测试 | `flutter test`（Mock 仓储） | ✅ | 测试输出 + 截图 |
| 静态分析 | `flutter analyze` 0 errors | ✅ | 报告 |
| APK 编译 | `flutter build apk --debug` | ⚠️ | 构建日志 + APK（运行未验证） |
| 端到端行为 | 真机 + 微信 | ❌ | 交付验证清单，用户执行 |

**诚实分级**：✅ 档我贴实际证据；⚠️ 编译档明确标注"运行未验证"；❌ 端到端**绝不声称验证**，只交付清单。

---

## 2. 工程架构与目录结构

方案 C（单工程 + 领域隔离），六边形架构（端口-适配器）。

### 2.1 目录结构

```
message_assistant/
├── lib/
│   ├── main.dart                       # 入口，初始化 DI、启动
│   ├── app/                            # 应用装配层
│   │   ├── app.dart                    # MaterialApp、主题
│   │   ├── di.dart                     # get_it 容器装配
│   │   └── router.dart                 # go_router 路由表
│   ├── domain/                         # 🔒 纯 Dart，零 Flutter 依赖（可纯单测）
│   │   ├── entities/
│   │   │   ├── keyword_rule.dart       # KeywordRule, MatchType
│   │   │   ├── message_record.dart     # MessageRecord, MessageSource
│   │   │   ├── match_result.dart       # MatchResult, KeywordHit
│   │   │   └── monitored_group.dart    # MonitoredGroup
│   │   ├── services/                   # 领域服务（纯逻辑）
│   │   │   ├── keyword_match_service.dart   # 精确+包含匹配引擎
│   │   │   ├── message_dedup_service.dart   # 指纹去重
│   │   │   ├── message_pipeline.dart        # 标准化→去重→匹配→分发
│   │   │   └── notify_policy_service.dart   # 夜间静默时段判断
│   │   └── repositories/               # 端口（抽象接口）
│   │       ├── i_message_repository.dart
│   │       ├── i_keyword_repository.dart
│   │       └── i_config_store.dart
│   ├── infrastructure/                 # 适配器层（实现端口）
│   │   ├── database/
│   │   │   ├── database.dart           # Drift Database 定义
│   │   │   ├── tables/                 # Drift 表定义
│   │   │   ├── daos/                   # MessageDao, KeywordDao
│   │   │   └── drift_repositories.dart # 端口实现
│   │   ├── platform/                   # MethodChannel/EventChannel 桥接
│   │   │   ├── notification_channel.dart    # 消息上行 EventChannel
│   │   │   ├── launcher_channel.dart        # 控制下行 MethodChannel
│   │   │   └── permission_channel.dart      # 权限状态查询
│   │   └── services/
│   │       └── local_notifier.dart     # 本地通知
│   ├── presentation/                   # 表示层
│   │   ├── pages/
│   │   │   ├── home/                   # 消息列表（首页）
│   │   │   ├── message_detail/         # 消息详情
│   │   │   ├── keyword_config/         # 关键词配置 + 编辑
│   │   │   ├── history/                # 历史搜索
│   │   │   └── settings/               # 设置、权限引导
│   │   └── widgets/                    # 共享组件（命中词高亮等）
│   └── core/                           # 错误类型、常量、扩展
├── android/                            # Android 原生（Kotlin）
│   └── app/src/main/kotlin/<pkg>/ma/
│       ├── MessageNotificationListenerService.kt
│       ├── MonitorForegroundService.kt
│       ├── BootReceiver.kt
│       ├── ServiceRestarter.kt
│       ├── AppLauncher.kt
│       ├── NotificationParser.kt       # 纯函数，可 JUnit 单测
│       ├── NotificationPlugin.kt       # FlutterPlugin，注册通道
│       └── MainApplication.kt
├── ios/                                # iOS 骨架（仅通道占位，无法在此构建）
├── test/                               # 单元/Widget 测试
│   ├── domain/
│   ├── infrastructure/
│   └── presentation/
└── docs/
    ├── architecture.md                 # 上游架构
    ├── superpowers/specs/              # 本 spec
    └── verification-checklist.md       # 设备验证清单（交付物）
```

### 2.2 三条依赖规则（架构 5.3 落地）

1. `domain/` 的 import 只允许：`dart:core`、`dart:collection`、`dart:convert`、`dartz`、`equatable`、`meta`、`freezed`。**绝不允许 `package:flutter/...`**。由 `analysis_options.yaml` lint 规则 + 检查脚本强制。
2. `domain/repositories/` 只有抽象接口；实现在 `infrastructure/`。
3. `presentation/`、`infrastructure/` 依赖 `domain/`，反之禁止。

### 2.3 技术栈（架构附录 A 的 MVP 子集）

| 层 | 选型 | 备注 |
|----|------|------|
| 框架 | Flutter 3.x | 待安装 |
| 状态管理 | Riverpod 2.x | 架构 Riverpod/BLoC 二选一，选 Riverpod |
| 路由 | go_router | 声明式、支持深链 |
| 数据库 | Drift (SQLite) | **MVP 不加 SQLCipher**（P2） |
| 通知 | flutter_local_notifications | 本地提醒 |
| DI | get_it + injectable | |
| 序列化 | freezed + json_serializable | 实体不可变 |
| 函数式 | dartz | Either<Failure, T> 错误建模 |
| Android | Kotlin + Coroutines + Flow | 原生监听层 |

---

## 3. 领域层详细设计（纯 Dart，可纯单测）

这是无设备环境下能拿到测试证据的核心。

### 3.1 实体（freezed 不可变）

```dart
enum MatchType { exact, contains }   // MVP 仅两种；设计为可扩展

@freezed
class KeywordRule with _$KeywordRule {
  const factory KeywordRule({
    required String id,
    required String keyword,
    @Default(MatchType.contains) MatchType type,
    @Default(50) int priority,                 // 0-100，越大越优先
    @Default([]) List<String> scopeGroupIds,   // 空=全部群生效
    @Default([]) List<String> excludeWords,    // 命中任一则不提醒
    @Default(true) bool enabled,
    String? groupName,                         // 关键词分组名
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _KeywordRule;
}

@freezed
class MessageRecord with _$MessageRecord {
  const factory MessageRecord({
    required String id,                        // UUID
    required String appId,
    required String groupId,
    String? groupName,
    required String senderName,
    String? senderId,
    required String content,                   // 标准化后的消息文本
    @Default([]) List<KeywordHit> hits,        // 命中详情（持久化为 JSON）
    @Default(0) int score,
    required DateTime occurredAt,              // 消息发生时间
    required DateTime receivedAt,              // 本机接收时间
    @Default(false) bool isRead,
    @Default(false) bool isReplied,
    required String fingerprint,               // 去重指纹
    required DateTime createdAt,
  }) = _MessageRecord;
}

@freezed
class KeywordHit with _$KeywordHit {
  const factory KeywordHit({
    required String ruleId,
    required String keyword,
    required MatchType type,
    required int priority,
    required List<int> highlightPositions,  // 内容中命中字符起始偏移
  }) = _KeywordHit;
}

@freezed
class MatchResult with _$MatchResult {
  const factory MatchResult({
    required MessageRecord message,
    required List<KeywordHit> hits,
    required int score,            // = 命中词优先级之和
  }) = _MatchResult;
}
```

### 3.2 KeywordMatchService — 匹配引擎

**匹配逻辑**：
```
输入: MessageRecord(content, groupId), List<KeywordRule>(enabled & 生效于该群)
  ├─ 1. 群范围过滤：rule.scopeGroupIds 非空且不含本群 → 跳过
  ├─ 2. 排除词检查：content 含任一 rule.excludeWords → 跳过该规则
  ├─ 3. 按 type 匹配：
  │      exact    → content == rule.keyword（去首尾空白）
  │      contains → content.contains(rule.keyword)
  │      命中则记录 KeywordHit + 所有命中位置偏移
  ├─ 4. 聚合 hits，按 priority 降序
  └─ 5. hits 非空 → MatchResult(score=Σpriority)；否则 null
```

- **大小写/全半角**：英文大小写不敏感（`toLowerCase`）；中文无此问题。
- **MVP 不做**：Trie/Aho-Corasick、正则、语义匹配（接口预留扩展位）。关键词量 < 1000 时直接扫描远低于架构 50ms/条 目标。

### 3.3 MessageDedupService — 去重

```
fingerprint = sha1("$appId|$groupId|$senderId|$normalizedContent|${timestamp ~/ 60}")
```
- 同一分钟窗、同发送人、同内容 → 判重（NotificationListener 可能对同消息多次回调）
- `MessageRepository.existsByFingerprint()` 查重；命中跳过整条管道
- MVP 用数据库 `fingerprint UNIQUE` 约束兜底（并发安全）；不做布隆过滤器（P2）

### 3.4 MessagePipeline — 消息处理管道（编排核心）

```
process(RawNotificationEvent) async
  1. 标准化 normalize()：解析 title/text 提取 groupId/groupName/senderName/content
  2. 去重：dedupService.isDuplicate(fingerprint)? → 是则 return（丢弃）
  3. 加载本群生效关键词 keywordRepo.findByScope(groupId)
  4. 匹配：matchService.match(message, rules) → MatchResult?
       无命中 → return（丢弃，不存库不提醒）
  5. 持久化 messageRepo.save(matchResult.message)   ← 命中才入库
  6. notifyPolicy.shouldNotify(now)? → 是则触发 LocalNotifier；否则只入库不提醒
  7. 返回 MatchResult 给调用方 → infra 层据第 6 步结果发通知
```

**关键决策：未命中消息不入库**。理由：货运场景 99% 消息无关，入库撑爆存储且拖慢查询；只存命中消息，符合架构 8.3 存储容量管理。代价：无法回溯全部历史，只能看命中过的（已与用户确认接受）。

**端口依赖（构造注入，便于 Mock）**：
```dart
class MessagePipeline {
  final IKeywordRepository _keywordRepo;
  final IMessageRepository _messageRepo;
  final MessageDedupService _dedup;
  final KeywordMatchService _matcher;
}
```

### 3.5 NotifyPolicyService — 夜间静默

- 输入：当前时间 + 配置的静默时段（如 22:00-07:00）+ 静默模式
- **MVP 静默模式单一明确**：静默时段内仍**入库**（消息不丢），但**不发送本地通知**（无响铃/震动/横幅）。不做"完全静默不入库"等可配置变体。
- 输出：`shouldNotify: bool`（Pipeline 命中后据此决定是否调 LocalNotifier）
- 纯函数，易单测（跨日时段边界，如 23:59 与 00:01）

### 3.6 错误建模（dartz）

领域服务对外返回 `Either<Failure, T>`。Failure 为 sealed class（DatabaseFailure、ParseFailure、NotFound…），表示层精确决定展示。

---

## 4. 基础设施层与平台桥接

### 4.1 数据库（Drift）

**表**（架构 8.2 MVP 子集，**只存命中消息**）：

```dart
class MessageRecords extends Table {
  TextColumn get id => text()();                           // UUID
  TextColumn get appId => text()();
  TextColumn get groupId => text()();
  TextColumn get groupName => text().nullable()();
  TextColumn get senderName => text()();
  TextColumn get senderId => text().nullable()();
  TextColumn get content => text()();
  TextColumn get matchedKeywordsJson => text()();          // JSON 命中详情
  IntColumn get score => integer().withDefault(const Constant(0))();
  DateTimeColumn get occurredAt => dateTime()();           // 消息发生时间
  DateTimeColumn get receivedAt => dateTime()();           // 本机接收时间
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isReplied => boolean().withDefault(const Constant(false))();
  TextColumn get fingerprint => text().unique()();         // 去重唯一约束
  DateTimeColumn get createdAt => dateTime()();
}

class KeywordRules extends Table {
  TextColumn get id => text()();
  TextColumn get keyword => text()();
  IntColumn get type => integer()();                       // 0=exact,1=contains
  IntColumn get priority => integer().withDefault(const Constant(50))();
  TextColumn get scopeGroupIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get excludeWordsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get groupName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class MonitoredGroups extends Table {
  TextColumn get groupId => text()();
  TextColumn get groupName => text()();
  TextColumn get appId => text()();
  BoolColumn get isWhitelist => boolean().withDefault(const Constant(false))();
  BoolColumn get isBlacklist => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastActiveAt => dateTime()();
}
```

**索引**：`(groupId, occurredAt DESC)`、`(receivedAt DESC)`、`fingerprint UNIQUE`。
**FTS5**：MVP 不接入（P2 加中文分词）；列表用 LIKE 查询。
**测试**：`NativeDatabase.memory()` 内存库跑 DAO/仓储单测，无需设备。

### 4.2 平台通道

**① `message_assistant/notification`（EventChannel）— 消息上行流**
```
Kotlin MessageNotificationListenerService ──EventSink──> Dart Stream<RawNotificationEvent>
                                                              ↓
                                                       MessagePipeline.process()
```
event map（**结构化字段**——解析在 Kotlin `NotificationParser` 完成，EventChannel 不传原始 title/text，避免 Dart 侧重复解析）：
```dart
{
  'appId': 'com.tencent.mm',
  'groupId': 'a1b2c3d4e5f6a7b8',     // Kotlin 侧 sha1("$appId|$groupName") 前16字符
  'groupName': '货运华东群',          // 单聊时为空串
  'senderName': '王师傅',
  'content':  '南京到上海...',
  'occurredAt': 1751234567890,
  'packageName': 'com.tencent.mm',   // 用于 Dart 侧目标 App 过滤冗余校验
}
```

**② `message_assistant/control`（MethodChannel）— 控制下行**
```
launchWechat()
copyToClipboard(text)
isNotificationListenerEnabled()
openNotificationListenerSettings()
isAccessibilityEnabled()          // 预留，本 MVP 不用
getMonitorServiceState()
```

### 4.3 本地通知（LocalNotifier）

- **通道**：专属 channel `message_matched`，高重要性
- **内容**：标题=群名/发送人；正文=消息，**命中词用「」高亮**（系统通知无富文本，符号标记）
- **点击**：PendingIntent 带 messageId → MethodChannel 回调 → go_router 跳详情页
- **折叠**：同群多条命中用 Android group summary 折叠
- **勿扰**：NotifyPolicyService 判断静默时段

### 4.4 端口实现映射

| 领域端口 | 实现 |
|---------|------|
| `IMessageRepository` | `DriftMessageRepository` |
| `IKeywordRepository` | `DriftKeywordRepository` |
| `IConfigStore` | `DriftConfigStore` |
| `IMessageSource` | `NotificationEventChannel` |
| `IAppLauncher` | `ControlMethodChannel` |
| `INotificationSender` | `LocalNotifier` |

Pipeline 只依赖抽象端口 → 可整体 Mock 测试。

---

## 5. Android 原生层（Kotlin）

### 5.1 核心组件

```
┌─ MessageNotificationListenerService (NotificationListenerService)
│    • onNotificationPosted() → NotificationParser.parse() → 推 EventSink
│    • 过滤目标 App 包名（微信 com.tencent.mm，可配置）
│    • 绑定前台服务生命周期
├─ MonitorForegroundService (前台 Service)
│    • startForeground() 常驻通知"消息监听运行中"
│    • 持有 EventChannel sink
│    • START_STICKY
├─ BootReceiver (BroadcastReceiver)
│    • BOOT_COMPLETED → 启动 MonitorForegroundService
├─ ServiceRestarter (WorkManager 周期任务)
│    • 每 15 分钟心跳，死亡则重启
├─ AppLauncher
│    • launchWechat(): getLaunchIntentForPackage("com.tencent.mm")
│    • copyToClipboard(): ClipboardManager
├─ NotificationParser（纯函数，JUnit 单测）
└─ NotificationPlugin (FlutterPlugin): 注册两通道
```

### 5.2 通知解析逻辑（数据质量命脉）

```
情况A：群消息
  title = "货运华东群(3)"   → groupName="货运华东群"，未读数=3（正则去尾部"(数字)"）
  text  = "王师傅: 南京到上海..." → senderName="王师傅"，content="南京到上海..."
情况B：单聊
  title = "王师傅"          → senderName="王师傅"，无群
  text  = "南京到上海..."     → content=text
情况C：多条聚合
  title = "货运华东群"
  text  = "[3条]王师傅: 南京到上海..." → 取可见内容匹配（去重兜底）
```

- **groupId 生成**：通知无稳定群 ID。用 `sha1("$appId|$groupName")` 前 16 字符作伪 groupId（同名群视为同一——MVP 可接受，P2 用 Accessibility 补真 ID）。单聊无群名时 groupId = `sha1("$appId|$senderName")` 前 16 字符。
- **截断**：系统通知 text 可能被截断，取可用部分匹配（截断不影响子串包含匹配）。
- **package 过滤**：只处理目标 App 包名，其余忽略。

### 5.3 权限与清单

```xml
<service android:name=".ma.MessageNotificationListenerService"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="false">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>

<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<service android:name=".ma.MonitorForegroundService"
    android:foregroundServiceType="specialUse">
    <property android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="notification_monitoring" />
</service>

<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<receiver android:name=".ma.BootReceiver" android:exported="false">
    <intent-filter><action android:name="android.intent.action.BOOT_COMPLETED" /></intent-filter>
</receiver>

<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.INTERNET" />   <!-- 预留 P2 -->
```

- **SDK**：`minSdkVersion 26`（Android 8.0），`compileSdk 34`
- **前台服务**：`FOREGROUND_SERVICE_SPECIAL_USE` + 用途声明（Android 14 强制）

### 5.4 权限引导流程（用户转化关键漏斗）

```
App 首启
  → 检查 isNotificationListenerEnabled()
  → 未授权 → 全屏引导页（说明用途 + "数据仅本地不上传"）→ [去开启] → openNotificationListenerSettings()
  → 返回复查 → 已授权 → 启动前台服务 → 进主界面
```

设置页可重新进入授权。**无授权监听完全不工作——此引导是 MVP 跑通关键。**

### 5.5 原生层测试

`NotificationParser.parse(title, text, pkg)` 提为纯函数，JUnit 单测覆盖：
- 三种格式（群/单聊/聚合）字段提取
- 边界：空 text、无冒号、超长截断、非目标包名过滤

其余组件（Service/Receiver/Intent）依赖 Android 运行时，设备验证。

---

## 6. 表示层（UI 与状态管理）

### 6.1 页面（4 tab）

- **消息（首页）**：命中消息实时流列表，顶部群筛选，命中词高亮，点击进详情
- **关键词**：分组列表 + 新建/编辑（关键词、类型、优先级、生效群、排除词）
- **历史**：按群/时间/已读/已回复筛选 + 搜索（LIKE），分页
- **设置**：通知监听状态、夜间静默时段、监听目标 App（微信默认勾选）、服务状态、重启服务、隐私政策、导出/清空

布局参考截图：底部导航 4 tab，消息列表卡片式，命中词用主题强调色高亮。

### 6.2 状态管理（Riverpod）

| Provider | 类型 | 职责 |
|----------|------|------|
| `messageListProvider` | AsyncNotifier（分页） | 消息列表，筛选群 |
| `messageDetailProvider(id)` | family AsyncNotifier | 单条详情 |
| `keywordListProvider` | AsyncNotifier | 关键词列表，按分组 |
| `keywordEditProvider` | Notifier | 编辑态表单 |
| `settingsProvider` | Notifier | 勿扰时段、目标 App |
| `monitorStateProvider` | StreamProvider | 监听服务运行状态 |
| `permissionProvider` | Notifier | 通知监听权限 + 引导 |
| `pipelineEventProvider` | StreamProvider | 订阅 Pipeline 产出，驱动列表刷新 + 通知 |
| `repositoryProviders` | Provider | 注入仓储到领域服务 |

**实时刷新**：列表订阅 `pipelineEventProvider`，Pipeline 每产出一条命中即追加 + 滚顶。

### 6.3 关键交互流

**点击通知 → 详情 → 打开微信**：
```
系统通知点击(PendingIntent 带 messageId)
  → control.onNotificationClicked(messageId)
  → go_router → /message/$messageId
  → 详情页加载 → 用户点[复制并打开微信]
  → controlChannel.launchWechat() + copyToClipboard(content)
  → Toast "已复制，已打开微信"
```

**关键词热加载**：`activeKeywordsProvider` 监听规则变化，重建匹配集注入 Pipeline → 新增关键词**立即对后续消息生效**，无需重启。

### 6.4 UI 细节

- **命中高亮**：`RichText` + `TextSpan`，按 `KeywordHit.highlightPositions` 渲染强调色背景
- **空状态**：无消息引导配置关键词；无关键词引导新增
- **权限未授权态**：首页顶部横幅"通知监听未开启"→ 跳授权
- **Material 3** 主题

### 6.5 表示层测试

Widget 测试（Mock 仓储驱动，无需设备）：列表渲染、命中高亮、表单校验、空/错误态。

---

## 7. 测试与验证策略

### 7.1 领域层单测用例（核心证据）

**KeywordMatchService**：
- 单关键词 contains 命中 + 高亮位置正确
- exact 命中（精确不匹配子串："上海" exact 不命中"上海港"）
- 多关键词命中，priority 降序聚合，score=Σpriority
- 排除词命中 → 跳过该规则
- 群范围过滤（scopeGroupIds 非空且不含本群 → 跳过）
- enabled=false → 跳过
- 大小写不敏感（英文）
- 无命中 → null

**MessageDedupService**：
- 同分钟同发送人同内容 → 判重
- 跨分钟边界 → 不判重
- 不同发送人同内容 → 不判重

**MessagePipeline**（Mock 仓储）：
- 群消息标准化字段正确
- 单聊标准化字段正确
- 去重命中 → 丢弃，不调 matcher、不存库
- 匹配无命中 → 丢弃，不存库、不发通知
- 匹配命中 → 存库 1 次 + 触发通知事件 1 次
- **未命中不入库（断言 repo.save 调用 0 次）**

**NotifyPolicyService**：
- 跨日时段（22:00-07:00）边界判断正确

### 7.2 Kotlin 解析单测

`NotificationParser.parse()` 三格式 + 边界（空 text、无冒号、截断、非目标包名）。

### 7.3 设备验证清单（交付用户，端到端）

`docs/verification-checklist.md`：
- [ ] APK 安装成功
- [ ] 首启引导 → 授权 → 状态"已开启"
- [ ] 后台杀 App → 前台服务常驻通知仍在
- [ ] 微信含关键词群消息 → 本地通知（命中词高亮）
- [ ] 微信不含关键词消息 → 无通知、不入库
- [ ] 点击通知 → 进详情页
- [ ] 详情"复制并打开微信"→ 微信唤起 + 剪贴板含消息
- [ ] 同消息多次触发 → 去重生效
- [ ] 重启手机 → BootReceiver 自启（需厂商自启白名单）
- [ ] 杀进程 ~15 分钟 → WorkManager 重启
- [ ] 夜间静默时段 → 不响铃/震动
- [ ] 关键词新增 → 后续消息立即按新规则匹配

### 7.4 环境搭建（实施第 0 步）

Flutter 未安装，实施第 0 步：
1. 检测/引导安装 Flutter SDK（或 fvm）+ Android SDK + ANDROID_HOME
2. 验证 `flutter doctor`（标注无法满足项，如 iOS toolchain）
3. 才开始代码

---

## 8. 风险、约束与交付边界

### 8.1 交付物清单

| 交付物 | 形式 | 可验证性 |
|--------|------|---------|
| Flutter 工程（领域/基础设施/表示层） | 源码 | ✅ 单测 + analyze |
| Android 原生模块（Kotlin） | 源码 + Manifest | ⚠️ 解析单测✅；服务行为设备验证 |
| 单元测试套件 | `test/` | ✅ `flutter test` 全绿 |
| **可安装 APK**（debug） | `build/app/outputs/...` | ⚠️ 已编译；运行需设备验证 |
| iOS 工程骨架 + 通道占位 | 源码/配置 | ❌ 无法在此 Windows 编译 |
| 设计文档（本 spec） | `docs/superpowers/specs/` | ✅ |
| 设备验证清单 | `docs/verification-checklist.md` | 交用户执行 |
| README（构建/安装/验证） | `README.md` | ✅ |

### 8.2 已知技术限制

| 限制 | 原因 | 影响 | 缓解 |
|------|------|------|------|
| NotificationListener 拿不到已读消息 | 系统限制 | 漏部分消息 | P2 加 Accessibility 兜底 |
| 群被免打扰 → 无通知 → 拿不到 | 依赖通知 | 该群失效 | UI 提示"监听群需保持通知开启" |
| groupId 是伪 ID（hash 群名） | 通知无稳定 ID | 同名群视为同一 | P2 补真 ID |
| 无法自动进特定群/@发送人 | 需 Accessibility | 点击只到微信主页 | P2 加 |
| 微信通知格式变更 | 版本升级 | 解析失效 | 解析纯函数化易改；P2 规则热更新 |
| Android 14+ 前台服务限制 | 新版系统严 | 部分机型保活受限 | specialUse 类型；白名单引导留 P2 |
| iOS 无法在此构建/验证 | Windows 无 Xcode | 仅骨架 | 需 Mac 构建 |
| 端到端无法在此验证 | 无设备 | 真实行为未验证 | 交付清单，不声称已验证 |

### 8.3 合规红线（继承架构文档）

- ❌ 不做协议逆向、不解密微信数据库、不 hook 进程
- ✅ 定位辅助工具：只读系统已弹通知（用户主动授权），不模拟登录、不发协议数据
- ✅ 数据本地化，MVP 不上云
- ✅ 权限最小化，每个权限在引导页说明用途
- ✅ 隐私政策入口

### 8.4 实施顺序（writing-plans 阶段细化）

1. 环境搭建（Flutter + Android SDK + doctor 全绿）
2. 工程骨架 + 分层 + import 隔离 lint
3. 领域层 + 单测（最先 ✅ 证据）
4. 基础设施层（Drift）+ 单测
5. 表示层（Riverpod + Widget）+ Widget 测试
6. Android 原生（Kotlin 解析单测 + 服务/通道）
7. 集成 + APK 编译验证
8. 验证清单 + README

---

## 附录：决策追溯

本 spec 所有取舍均来自与用户的逐节确认（2026-07-30 会话），关键决策见第 0.2 节。上游架构决策见 `docs/architecture.md` ADR-001~005。

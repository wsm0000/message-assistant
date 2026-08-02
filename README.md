# 消息提醒器助手 (Message Assistant)

货运/物流接单助手：监听微信群通知 → 关键词匹配 → 本地提醒 → 一键唤起微信回复。附出行距离/费用估算（高德地图）。

> **平台**：Android（iOS 仅骨架，需 Mac 构建）
> **Flutter** 3.44 / Dart 3.12 · **架构**：六边形（端口-适配器）

---

## 它做什么

司机加入很多货运微信群，消息太多盯不过来。本 App：

1. **监听微信群通知**（Android NotificationListenerService）。
2. **关键词匹配**消息内容（精确 / 包含匹配，支持排除词、生效群、优先级）。
3. **本地提醒**（通知 + 震动，可设夜间静默）。
4. 点击提醒 → 进 App 详情 → 点"回复"选话术 → **自动组装 `@发送人 话术` 复制到剪贴板 + 唤起微信群聊**，粘贴即发。
5. **快捷话术管理**（预设"接单/已发车/稍后联系/已满"，可增删改、设默认、自定义）。
6. **统计仪表盘**（今日命中、7 天趋势、群/词排行）。
7. **出行距离/费用估算**（高德地图 REST：输入起终点地址 → 距离 + 时长 + 网约车费用参考价）。

---

## 整体架构

采用**六边形架构（端口-适配器）**，domain 层保持纯 Dart（由 `tool/domain_lint.dart` 强制约束，禁止 import 任何外部 package）。

```
lib/
├── app/                        # 应用入口与路由
│   ├── app.dart                # 根 widget (MaterialApp.router + 生命周期)
│   └── router.dart             # go_router (StatefulShellRoute 4 tab)
│
├── domain/                     # 领域层（纯 Dart，无外部依赖）
│   ├── entities/               # 值对象: MessageRecord, KeywordRule, RouteEstimate, FareRule, Failure...
│   ├── repositories/           # 端口(接口): IMessageRepository, IKeywordRepository, IRouteGateway...
│   └── services/               # 领域逻辑: MessagePipeline, KeywordMatchService, NotifyPolicyService...
│
├── infrastructure/             # 基础设施层（适配器实现）
│   ├── database/               # Drift (SQLite): database.dart, drift_repositories, daos, tables
│   ├── platform/               # MethodChannel/EventChannel 桥接: notification_channel, auto_reply_channel
│   ├── amap/                   # 高德地图 REST 适配器: amap_route_gateway, fare_rules
│   ├── services/               # local_notifier (flutter_local_notifications)
│   └── storage/                # 内存仓储实现 (测试用)
│
├── presentation/               # 表现层
│   ├── pages/                  # 各功能页面
│   │   ├── home/               # 首页 (分组折叠消息列表)
│   │   ├── message_detail/     # 消息详情 + 回复 (reply_sheet 智能复制)
│   │   ├── keyword_config/     # 关键词配置 (列表/编辑)
│   │   ├── history/            # 历史记录
│   │   ├── stats/              # 统计仪表盘
│   │   ├── route_calc/         # 出行距离/费用计算
│   │   ├── settings/           # 设置
│   │   └── onboarding/         # 引导
│   ├── providers/              # Riverpod provider 装配 (providers.dart)
│   ├── widgets/                # 共享组件: MessageTile, KeywordHighlightText
│   └── utils/                  # 工具: date_format
│
└── main.dart                   # 入口 (ProviderScope)
```

### 技术栈

| 层面 | 技术 |
|---|---|
| 框架 | Flutter 3.44 / Dart 3.12 |
| 状态管理 | Riverpod 2.x（手写 provider，无 codegen）|
| 路由 | go_router（StatefulShellRoute + 底部导航 4 tab）|
| 数据库 | Drift (SQLite) |
| 模型 | freezed + json_serializable |
| 函数式 | dartz（`Either<Failure, T>` 错误处理）|
| 网络 | dio（高德 REST API）|
| 通知 | flutter_local_notifications |
| 图表 | fl_chart |

---

## Android 原生组件

```
android/app/src/main/kotlin/com/example/message_assistant/
├── MainActivity.kt                  # FlutterFragmentActivity (规避后台黑屏)
├── MainApplication.kt
├── NotificationPlugin.kt            # FlutterPlugin + ActivityAware (EventChannel/MethodChannel 桥接)
├── MessageNotificationListenerService.kt  # 监听微信通知 (NotificationListenerService)
├── NotificationParser.kt            # 解析微信通知 (发送人/内容/群)
├── MonitorForegroundService.kt      # 前台保活服务 (持有 eventSink)
├── JumpIntentStore.kt               # contentIntent 存储 (跳转微信群聊)
├── AppLauncher.kt                   # 唤起微信 / 复制剪贴板
├── BootReceiver.kt                  # 开机自启
└── ServiceRestarter.kt             # 服务自恢复
```

### 关键能力

- **NotificationListenerService**：捕获微信群通知（需用户在系统设置授权"通知使用权"）。
- **contentIntent 跳群**：捕获微信通知的 PendingIntent，回复时直接跳进对应群聊（绕过微信首页）。
- **前台服务保活**：MonitorForegroundService 保持进程前台优先级，防止被系统杀死。
- **开机自启 + 自恢复**：BootReceiver + ServiceRestarter 保证服务持续运行。

---

## 核心数据流

```
微信群通知
  → NotificationListenerService.onNotificationPosted()
  → NotificationParser 解析 (发送人/内容/群名)
  → EventChannel "message_assistant/notification" 推送到 Flutter
  → MessagePipeline.process()
      ├→ MessageDedupService 去重 (1分钟桶)
      ├→ KeywordMatchService 关键词匹配
      └→ 命中 → IMessageRepository 存储 + LocalNotifier 弹通知
  → messageListProvider 刷新 → 首页分组列表更新
```

---

## 功能列表

### 消息监听与匹配
- ✅ 监听微信群通知（NotificationListenerService）
- ✅ 关键词匹配（精确 / 包含，排除词、生效群、优先级）
- ✅ 消息去重（1 分钟时间桶）
- ✅ 本地通知提醒（通知 + 震动，夜间静默策略）

### 消息展示
- ✅ 首页分组折叠（按群分组，ExpansionTile，默认折叠）
- ✅ 每个群展示最新消息预览 + 时间 + 消息数
- ✅ 已回复（红色边框）/ 未回复（绿色按钮）颜色区分
- ✅ "回复最新"快捷按钮（折叠态可用）
- ✅ 统计仪表盘（今日/总数/未读/回复率、7天趋势图、群/词排行）
- ✅ 历史记录页

### 回复
- ✅ 智能复制：组装 `@发送人 话术` → 复制剪贴板 → 跳转微信群聊
- ✅ 快捷话术管理（预设/自定义/设默认）
- ✅ contentIntent 精准跳群

### 出行工具
- ✅ 高德地图距离/费用估算（地址→经纬度→距离/时长→网约车费用）

---

## 快速开始

### 环境要求
- Flutter 3.44+
- Android Studio / VS Code
- Android 设备（API 26+，实测华为 Android 12）

### 构建运行
```bash
flutter pub get
flutter run                    # debug 模式连接设备
# 或构建 APK
flutter build apk --debug
```

### 配置

1. **高德 API Key**（出行距离功能需要）：
   - 去 [高德开放平台](https://lbs.amap.com) 创建"Web服务"类型应用，获取 Key
   - 填入 `lib/infrastructure/amap/amap_route_gateway.dart` 的 `amapApiKey`

2. **Android 权限授权**（安装后首次运行）：
   - **通知使用权**：设置 → 通知 → 通知使用权 → 开启"消息助手"
   - 没有这个权限，App 收不到微信群通知

### 测试
```bash
flutter test                   # 运行所有测试
dart run tool/domain_lint.dart # 校验 domain 层无外部依赖
```

---

## 项目结构约束

- **domain 层纯 Dart**：`tool/domain_lint.dart` 强制禁止 import 外部 package（仅允许 dartz/equatable/freezed/json_annotation/uuid/crypto）。所有高德/dio/Flutter 类型严格隔离在 infrastructure 层。
- **手写 Riverpod**：因 analyzer_plugin 兼容问题，不使用 riverpod_generator codegen，所有 provider 手写在 `providers.dart`。
- **Either 错误处理**：所有 repository 方法返回 `Future<Either<Failure, T>>`，错误类型见 `domain/entities/failure.dart`。

---

## 文档

- [`docs/architecture.md`](docs/architecture.md) — 原始架构设计文档（ADR、功能路线图）

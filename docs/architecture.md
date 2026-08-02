# 消息提醒器助手 — 整体架构设计

> **文档版本**: v1.0
> **创建日期**: 2026-07-30
> **架构师**: Software Architect
> **状态**: 待评审 (Proposed)

---

## 目录

1. [需求分析](#1-需求分析)
2. [核心挑战与技术约束](#2-核心挑战与技术约束)
3. [架构原则](#3-架构原则)
4. [架构决策记录 (ADR)](#4-架构决策记录-adr)
5. [整体架构（C4 分层视图）](#5-整体架构c4-分层视图)
6. [核心模块详细设计](#6-核心模块详细设计)
7. [跨平台消息监听方案](#7-跨平台消息监听方案)
8. [数据模型设计](#8-数据模型设计)
9. [关键流程设计](#9-关键流程设计)
10. [质量属性设计](#10-质量属性设计)
11. [长期演进规划](#11-长期演进规划)
12. [风险与缓解措施](#12-风险与缓解措施)

---

## 1. 需求分析

### 1.1 业务场景还原

从界面截图分析，这是一个**货运/物流行业的接单助手**：

```
典型用户故事：
  货运司机小王加入了 20+ 个货运微信群
  → 群内每分钟产生大量消息，人工盯屏成本高
  → 他关心"南京到上海"、"台州到南通"等线路信息
  → 设置关键词："到"、"南京"、"上海"、"台州"、"南通"
  → 任何群里出现匹配消息立即推送提醒
  → 点击提醒直接跳转到对应群，自动@发送人
  → 一键回复"接单"完成抢单
```

### 1.2 功能需求清单

| # | 功能 | 优先级 | 复杂度 |
|---|------|--------|--------|
| F1 | 关键词配置管理（增删改查、分组、优先级） | P0 | 低 |
| F2 | 监听指定 App 的群聊消息（通知+界面） | P0 | **极高** |
| F3 | 关键词匹配与消息过滤 | P0 | 中 |
| F4 | 匹配消息持久化（群名、发送人、内容、时间） | P0 | 低 |
| F5 | 实时提醒（本地通知、震动、铃声） | P0 | 低 |
| F6 | 点击跳转到目标群聊 | P0 | **高** |
| F7 | 自动@发送人 | P0 | **高** |
| F8 | 快捷回复（预设话术、一键发送） | P1 | 中 |
| F9 | 历史记录查询与搜索 | P1 | 低 |
| F10 | 关注/好友标记与过滤 | P1 | 中 |
| F11 | 工具浮窗（悬浮球、快捷操作） | P1 | 中 |
| F12 | 多 App 支持（微信、QQ、企微、钉钉、飞书） | P2 | 高 |
| F13 | 数据统计与可视化 | P2 | 中 |
| F14 | 云端同步与多设备 | P3 | 高 |

### 1.3 非功能需求

| 维度 | 目标 | 说明 |
|------|------|------|
| **实时性** | 消息延迟 < 500ms | 从群消息弹出到本地提醒 |
| **稳定性** | 7×24 后台运行 | 不被系统杀死，崩溃自恢复 |
| **隐私** | 数据本地化 | 群聊内容敏感，优先本地存储 |
| **性能** | 匹配 < 50ms/条 | 千级关键词下保持流畅 |
| **兼容性** | Android 8+, iOS 14+ | 覆盖 95%+ 主流设备 |
| **功耗** | 增量功耗 < 5%/天 | 后台监听不能显著耗电 |

---

## 2. 核心挑战与技术约束

### 2.1 平台能力不对称 —— 最大的架构风险

这是整个系统的**根本性约束**，必须先讲清楚：

| 能力 | Android | iOS | 差距 |
|------|---------|-----|------|
| 读取其他App通知内容 | ✅ NotificationListenerService | ⚠️ Notification Service Extension（受限） | 中 |
| 读取其他App界面内容 | ✅ AccessibilityService | ❌ 完全不可能 | **巨大** |
| 模拟点击/输入 | ✅ AccessibilityService | ❌ 不可能 | **巨大** |
| 跳转到指定群聊 | ✅ Intent + 已 Root 可深链 | ⚠️ URL Scheme 有限支持 | 大 |
| 自动@某人 | ✅ 辅助功能模拟输入 | ❌ 需用户手动操作 | 大 |
| 后台长期存活 | ✅ 前台服务+保活 | ⚠️ 严格限制（30秒规则） | 中 |

**结论**：Android 是完整功能平台，iOS 是受限功能平台。架构设计必须**容忍这种不对称**，不能强行追求功能对齐。

### 2.2 目标 App 的对抗性

微信、QQ 等 App **不欢迎**被监听：

- 微信 UI 结构频繁变更，AccessibilityService 的节点路径会失效
- 部分版本对节点添加混淆、加密文本
- 厂商可能检测并屏蔽辅助功能
- **合规风险**：过度使用可能违反《个人信息保护法》和微信用户协议

**缓解**：把"对目标 App 的适配"抽象为**可热更新的规则插件**，主程序与适配代码解耦。

### 2.3 关键词匹配的工程挑战

- 用户可能配置几百个关键词，每条消息都要全量匹配
- 需要支持精确匹配、模糊匹配、正则、排除词
- 多关键词命中时的优先级与去重
- 匹配过程不能阻塞 UI 线程

---

## 3. 架构原则

1. **领域优先，平台适配** —— 核心业务（关键词、消息、规则）与平台能力（监听、跳转）严格分离
2. **可降级设计** —— iOS 缺失的能力必须有降级方案，而不是直接报错
3. **本地优先** —— 数据默认存本地，云端是可选增强
4. **规则外置** —— 目标 App 的 UI 适配规则可热更新，不发版也能适配微信新版本
5. **隐私最小化** —— 只采集必要字段，敏感内容加密存储
6. **可逆性优先** —— 每个技术决策都要能低成本回退

---

## 4. 架构决策记录 (ADR)

### ADR-001: 跨平台框架选择 — Flutter

**Status**: Proposed

**Context**
需要同时支持 Android 和 iOS，团队规模有限，不能维护两套原生代码。核心 UI（列表、详情、设置）在两个平台高度一致，但底层监听能力完全不同。

**Options Considered**

| 方案 | 优势 | 劣势 |
|------|------|------|
| **Flutter** | UI一致性最好、性能接近原生、Platform Channel成熟 | Dart生态较小、原生插件需自研 |
| React Native | JS生态大、热更新容易 | 列表性能较差、原生桥接复杂 |
| Kotlin Multiplatform | 共享业务逻辑、UI原生 | 生态新、iOS支持仍在Beta |
| 原生双端 | 体验最佳、平台能力完整 | 人力翻倍、迭代慢 |

**Decision**
采用 **Flutter + Platform Channel** 架构：
- 上层 UI、业务逻辑、数据模型用 Dart 实现（代码复用率 ~85%）
- 平台特定能力（无障碍服务、通知扩展）通过 MethodChannel 暴露
- 复杂的原生模块（监听引擎）用 Kotlin / Swift 实现，作为 Library 集成

**Consequences**
- ✅ 一套 UI 代码，降低维护成本
- ✅ 性能足够支撑高频消息列表
- ✅ Platform Channel 异步通信，不阻塞 UI
- ❌ 需要团队掌握 Dart + Kotlin + Swift 三种语言
- ❌ Flutter 引擎包体积增大 ~8MB
- 🔄 可逆性：业务层抽象良好，未来可替换 UI 层

---

### ADR-002: Android 监听方案 — AccessibilityService 为主，NotificationListener 为辅

**Status**: Proposed

**Context**
Android 上读取其他 App 消息有两种系统级途径，各有优劣。

**Options Considered**

| 方案 | 能拿到什么 | 限制 |
|------|-----------|------|
| **AccessibilityService** | 完整聊天界面（群名、发送人、消息内容、时间戳） | 需用户手动授权、目标App改版会失效 |
| **NotificationListenerService** | 通知栏消息（标题=群名/发送人，内容=消息） | 拿不到已读消息、群被免打扰时无通知、信息维度少 |
| Root + Xposed | 一切 | 需Root，用户群极小，安全风险高 |
| 录屏 + OCR | 屏幕内容 | 功耗高、准确率低、隐私风险大 |

**Decision**
**双引擎并行，智能融合**：
- **主引擎**：AccessibilityService —— 监听微信界面变化，拿到完整结构化数据
- **副引擎**：NotificationListenerService —— 作为兜底（App 不在前台时仍能捕获）
- **融合层**：去重（同一时间窗内同内容消息只保留一份）、补全（通知消息补充群信息）

**Consequences**
- ✅ 覆盖前台+后台两种场景
- ✅ 通知监听可作为 Accessibility 失效时的兜底
- ❌ 两个引擎的数据需要对齐，去重逻辑复杂
- ❌ Accessibility 授权引导是用户转化的关键漏斗
- 🔄 可逆性：引擎抽象为接口，可单独替换

---

### ADR-003: iOS 监听方案 — Notification Service Extension + App Group 共享

**Status**: Proposed

**Context**
iOS 沙盒机制严格，App 之间无法互相读取数据。唯一可行的途径是 **Notification Service Extension**（通知服务扩展），它在系统展示推送通知前短暂拦截并处理。

**Decision**
```
[微信服务器推送] → [APNs] → [iOS系统]
                                    ↓
                          [Notification Service Extension]
                                    ↓ 拦截通知
                          [解析 title/body]
                                    ↓
                          [关键词匹配（本地）]
                                    ↓
                          [写入 App Group 共享存储]
                                    ↓
                          [修改通知内容 / 触发本地通知]
                                    ↓
                          [主 App 读取共享存储展示]
```

**关键限制与妥协**：
- 扩展只有 **30 秒**执行时间，无法做复杂计算
- 只能处理**推送通知**，用户在 App 内已读的消息拿不到
- 无法自动跳转到指定群（微信 iOS 的 URL Scheme 不支持群聊 ID 直达）
- **无法自动@某人**，只能跳转到微信首页让用户手动操作

**Consequences**
- ✅ 在 iOS 限制内实现了"监听-匹配-提醒"的核心闭环
- ❌ 功能对比 Android 严重缩水（无跳转、无@、仅通知）
- ❌ 依赖微信服务器推送，无网/弱网时延迟不可控
- ⚠️ 必须在用户协议中明确说明 iOS 功能限制

---

### ADR-004: 数据存储 — SQLite 本地为主，端到端加密云同步可选

**Status**: Proposed

**Context**
消息记录包含群聊内容，属于敏感个人信息。同时需要支持历史查询、关键词搜索、统计分析。

**Options Considered**

| 方案 | 优势 | 劣势 |
|------|------|------|
| **SQLite (Drift/Floor)** | 成熟、支持复杂查询、事务安全 | 需手写迁移 |
| Hive (NoSQL) | 读写快、无 Schema 负担 | 复杂查询弱、无 SQL |
| Realm | 对象即数据库、跨平台 | 包体积大、维护成本高 |
| 云端为主 | 多设备同步 | 隐私风险、离线不可用 |

**Decision**
- **本地存储**：Flutter **Drift**（SQLite 的类型安全封装）
  - 消息表、关键词表、群映射表、配置表
  - 敏感字段（消息内容、发送人昵称）使用 **SQLCipher** 加密
- **搜索**：SQLite FTS5 全文索引，支持中文分词（jieba 或 simple）
- **云同步（V3 可选）**：端到端加密（E2EE），密钥仅存在用户设备
  - 服务器只存密文，无法读取内容

**Consequences**
- ✅ 离线可用，响应快
- ✅ 隐私保护到位（本地加密 + E2EE）
- ❌ 本地存储容量需管理（LRU 清理策略）
- ❌ E2EE 增加密钥管理复杂度

---

### ADR-005: 规则引擎 — 声明式配置 + 热更新

**Status**: Proposed

**Context**
目标 App（特别是微信）UI 结构会随版本变化。如果每次微信更新都要发版，维护成本不可接受。

**Decision**
将"如何从一个 App 界面提取消息"定义为**声明式规则**（JSON/YAML），从服务器下发：

```yaml
# 微信 v8.0.x 群聊界面适配规则（示例）
app: com.tencent.mm
version: ">=8.0.40"
chat_list:
  container_id: "com.tencent.mm:id/xxx_list"
  item_xpath: "//androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout"
  fields:
    group_name:
      node_id: "com.tencent.mm:id/tv_group_name"
      type: text
    sender:
      node_id: "com.tencent.mm:id/tv_sender"
      type: text
    content:
      node_id: "com.tencent.mm:id/tv_content"
      type: text
      highlight_regex: ".*"
```

- 规则版本化、可灰度下发、可回滚
- 主 App 内置解析引擎，按当前微信版本加载对应规则
- 规则更新走 CDN，无需应用商店审核

**Consequences**
- ✅ 微信改版后小时级响应，不用发版
- ✅ 支持多版本微信并存（老用户不升级也能用）
- ❌ 规则引擎本身有学习成本
- ❌ 需要持续跟踪目标 App 更新（运营工作）

---

## 5. 整体架构（C4 分层视图）

### 5.1 Level 1: 系统上下文

```
┌─────────────────────────────────────────────────────────────────┐
│                          用户 (司机/接单员)                        │
└────────────┬────────────────────────────────────────────────────┘
             │ 使用
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    消息提醒器助手 (本系统)                          │
│                                                                  │
│   监听群聊 → 关键词匹配 → 本地提醒 → 跳转回复                       │
└──────┬──────────────┬──────────────┬──────────────┬─────────────┘
       │              │              │              │
       ▼ 监听         ▼ 监听         ▼ 跳转         ▼ 可选同步
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  微信        │ │  QQ/钉钉    │ │  目标App    │ │  云端服务    │
│  (主要目标)  │ │  (次要目标)  │ │  (唤起)     │ │  (V3+)      │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
```

### 5.2 Level 2: 容器架构

```
┌──────────────────────────────────────────────────────────────────────┐
│                          Flutter App (跨平台 UI 层)                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ 消息列表页   │  │ 关键词配置页 │  │ 历史/统计页  │  │ 设置/我的页  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │
│  ┌──────────────────────────────────────────────────────────────────┐│
│  │              应用层 (Use Cases / BLoC / Riverpod)                 ││
│  └──────────────────────────────────────────────────────────────────┘│
│  ┌──────────────────────────────────────────────────────────────────┐│
│  │              领域层 (Entities / Repositories / Services)          ││
│  │   • KeywordMatcher    • MessageProcessor    • GroupRegistry      ││
│  └──────────────────────────────────────────────────────────────────┘│
│  ┌──────────────────────────────────────────────────────────────────┐│
│  │              基础设施层 (Platform Channel / DB / Network)         ││
│  └──────────────────────────────────────────────────────────────────┘│
└────────────┬───────────────────────────────────────────┬─────────────┘
             │ MethodChannel                             │ MethodChannel
             ▼                                           ▼
┌──────────────────────────────────┐      ┌──────────────────────────────┐
│      Android 原生模块 (Kotlin)     │      │    iOS 原生模块 (Swift)        │
│  ┌────────────────────────────┐  │      │  ┌────────────────────────┐  │
│  │ AccessibilityMonitor       │  │      │  │ NotificationExtension  │  │
│  │ (无障碍监听引擎)            │  │      │  │ (通知拦截扩展)          │  │
│  ├────────────────────────────┤  │      │  ├────────────────────────┤  │
│  │ NotificationListener       │  │      │  │ AppGroupStorage        │  │
│  │ (通知监听兜底)              │  │      │  │ (跨进程共享存储)        │  │
│  ├────────────────────────────┤  │      │  ├────────────────────────┤  │
│  │ AppLauncher                │  │      │  │ URLLauncher            │  │
│  │ (跳转+@模拟)               │  │      │  │ (有限跳转)             │  │
│  ├────────────────────────────┤  │      │  └────────────────────────┘  │
│  │ FloatingWindow             │  │      └──────────────────────────────┘
│  │ (悬浮球)                   │  │
│  ├────────────────────────────┤  │
│  │ RuleEngine                 │  │
│  │ (规则解析与热更新)          │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 5.3 Level 3: 领域层组件划分

采用**六边形架构**（端口-适配器），领域层不依赖任何框架：

```
┌──────────────────────────── 领域核心 (纯 Dart，无平台依赖) ────────────────────────────┐
│                                                                                       │
│  ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐                  │
│  │  Keyword         │   │  Message         │   │  Group           │                  │
│  │  (关键词聚合)     │   │  (消息聚合)       │   │  (群组聚合)       │                  │
│  │  • KeywordRule   │   │  • MessageRecord │   │  • MonitoredGroup│                  │
│  │  • MatchPolicy   │   │  • MatchResult   │   │  • GroupMapping  │                  │
│  └────────┬─────────┘   └────────┬─────────┘   └────────┬─────────┘                  │
│           │                      │                      │                            │
│  ┌────────▼──────────────────────▼──────────────────────▼─────────┐                  │
│  │                    领域服务 (Domain Services)                    │                  │
│  │  • KeywordMatchService      • MessageDeduplicationService      │                  │
│  │  • NotificationPolicyService • QuickReplyService               │                  │
│  └─────────────────────────────────────────────────────────────────┘                  │
│                                                                                       │
│  ┌──────────────────────────────── 端口 (Ports / 抽象接口) ──────────────────────────┐│
│  │  IMessageSource    INotificationSender    IAppLauncher    IRuleRepository         ││
│  │  IMessageRepository IKeywordRepository    IConfigStore    ICryptoService          ││
│  └───────────────────────────────────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────────────────────────────────┘
                                              ▲
              ┌───────────────────────────────┼───────────────────────────────┐
              │                               │                               │
   ┌──────────┴─────────┐         ┌──────────┴──────────┐         ┌──────────┴─────────┐
   │   Android 适配器    │         │    iOS 适配器        │         │   共享适配器        │
   │  AccessibilityImpl │         │  NotificationExtImpl │         │  DriftRepository   │
   │  NotificationImpl  │         │  AppGroupStorageImpl │         │  SqlCipherCrypto   │
   │  IntentLauncher    │         │  URLLauncherImpl     │         │  DioHttpClient     │
   └────────────────────┘         └─────────────────────┘         └────────────────────┘
```

**关键依赖规则**：
- 外层依赖内层，内层不知道外层的存在
- 领域层零第三方依赖（除 dartz/equatable 等纯函数库）
- 平台能力通过端口注入，Mock 实现可独立测试

---

## 6. 核心模块详细设计

### 6.1 关键词匹配引擎

**设计目标**：单条消息匹配耗时 < 50ms，支持 1000+ 关键词

```
┌─────────────────────────────────────────────────────────────────┐
│                      KeywordMatchEngine                         │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              关键词索引 (启动时构建，热更新)                │  │
│  │                                                            │  │
│  │   精确匹配 → HashSet<O(1)>                                 │  │
│  │   前缀匹配 → Trie 树                                       │  │
│  │   子串匹配 → Aho-Corasick 自动机 (多模式串匹配)             │  │
│  │   正则匹配 → 预编译 RegExp 池 (限制数量防 ReDoS)            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              匹配策略链 (Chain of Responsibility)           │  │
│  │                                                            │  │
│  │   1. 白名单过滤 (关注群/好友优先)                           │  │
│  │   2. 黑名单过滤 (排除群/排除词)                             │  │
│  │   3. 精确匹配 (O(1) 快速通道)                               │  │
│  │   4. 多模式匹配 (AC 自动机一次扫描)                          │  │
│  │   5. 正则匹配 (慢速兜底)                                    │  │
│  │   6. 语义匹配 (V3+, 本地小模型)                             │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              结果聚合                                       │  │
│  │   • 命中关键词列表（按优先级排序）                            │  │
│  │   • 高亮位置（用于 UI 渲染）                                 │  │
│  │   • 匹配分数（用于排序与降噪）                                │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**核心数据结构**：

```dart
// 关键词规则
class KeywordRule {
  final String id;
  final String keyword;              // 关键词内容
  final MatchType type;              // exact | prefix | contains | regex | semantic
  final int priority;                // 优先级 0-100
  final List<String> scopeGroupIds;  // 生效群组（空=全部）
  final List<String> excludeWords;   // 排除词（命中则不提醒）
  final NotifyPolicy notifyPolicy;   // 提醒策略
  final bool enabled;
  final DateTime createdAt;
}

// 匹配结果
class MatchResult {
  final MessageRecord message;
  final List<KeywordHit> hits;       // 命中的关键词及位置
  final double score;                // 综合得分
  final NotifyPolicy policy;         // 合并后的提醒策略
}
```

### 6.2 消息处理管道

```
[原始事件] → [标准化] → [去重] → [匹配] → [持久化] → [提醒] → [UI更新]
              ↓           ↓        ↓         ↓          ↓         ↓
           ParseRaw    Dedup    Match    SaveDB    Notify   RefreshUI
           提取字段     指纹比对  关键词引擎  事务写入   本地通知  BLoC事件
```

**关键设计**：

1. **去重策略**：消息指纹 = `SHA1(appId + groupId + senderId + content + floor(timestamp/60))`
   - 同一分钟内的同内容消息视为重复
   - 布隆过滤器（Bloom Filter）做前置快速判断，Redis-like 内存结构做精确判断

2. **背压处理**：高频群消息洪峰时（如 100条/秒）
   - 消息队列缓冲（内存 RingBuffer，容量 1000）
   - 批量写入数据库（每 200ms 或满 50 条批量提交）
   - UI 层只通知"有更新"，不推每条详情

3. **背压丢弃策略**：队列满时丢弃低优先级消息（非白名单群的普通消息）

### 6.3 跳转与回复执行器

**Android 完整链路**：

```
用户点击"回复"
    ↓
检查微信是否在前台 ──否──> 通过 Intent 唤起微信 MainActivity
    ↓ 是                            ↓
通过 AccessibilityService            等待微信启动
    ↓                                ↓
查找目标群聊 ────────────────────────┘
    ↓
  方案A: 通过 Intent extras 直接传入群 ID（需微信支持，不稳定）
  方案B: 模拟用户操作路径：首页 → 搜索 → 输入群名 → 点击进入
    ↓
进入群聊界面
    ↓
定位输入框 → 注入 "@" → 触发联系人选择 → 搜索发送人昵称 → 选中
    ↓
注入预设回复文本（或等待用户输入）
    ↓
用户确认 → 模拟点击发送按钮
```

**关键风险**：每一步都可能失败（UI 改版、弹窗干扰、网络延迟）
- 每步设置超时（默认 3s）和重试（最多 2 次）
- 失败时降级：只跳转到微信首页，提示用户手动操作
- 全程无障碍操作日志，便于排查问题

**iOS 降级链路**：
```
用户点击"回复"
    ↓
复制预设文本到剪贴板
    ↓
URL Scheme 唤起微信 (weixin://)
    ↓
Toast 提示："已复制回复内容，请粘贴发送"
```

### 6.4 悬浮球工具

参考截图右下角的"工具"浮窗：

```
┌────────────────────────────────────┐
│         FloatingWindowManager      │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  悬浮球主入口 (可拖动)         │  │
│  │  • 长按拖动位置                │  │
│  │  • 单击展开工具面板             │  │
│  │  • 边缘自动吸附                │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  工具面板                     │  │
│  │  • 一键喊话（向最近匹配群发送） │  │
│  │  • 复制最新匹配消息             │  │
│  │  • 暂停/恢复监听               │  │
│  │  • 打开主 App                  │  │
│  │  • 查看今日统计                │  │
│  └──────────────────────────────┘  │
│                                    │
│  Android: SYSTEM_ALERT_WINDOW 权限 │
│  iOS:    无法实现（系统限制）        │
└────────────────────────────────────┘
```

---

## 7. 跨平台消息监听方案

### 7.1 方案对比矩阵

| 方案 | 平台 | 能获取的字段 | 实时性 | 稳定性 | 合规风险 |
|------|------|-------------|--------|--------|----------|
| AccessibilityService | Android | 全部（群名/发送人/内容/时间/已读状态） | 毫秒级 | 中（依赖UI结构） | 中 |
| NotificationListener | Android | 通知标题/内容（无群ID） | 秒级 | 高 | 低 |
| Notification Service Ext | iOS | 通知标题/内容 | APNs延迟(1-5s) | 高 | 低 |
| URL Scheme 跳转 | 双端 | 无（仅跳转） | - | 中 | 低 |
| Root/Xposed | Android | 全部+更多 | 毫秒级 | 低 | **高** |
| 录屏+OCR | 双端 | 屏幕可见内容 | 秒级 | 低 | **高** |
| 协议逆向 | - | 全部 | 毫秒级 | 极低 | **极高（违法）** |

**红线**：协议逆向（ hook 微信进程、解密数据库）**绝对不做**，法律风险不可接受。

### 7.2 Android 详细实现

```kotlin
// 核心 AccessibilityService 骨架
class MessageAccessibilityService : AccessibilityService() {

    private val ruleEngine: RuleEngine by inject()
    private val eventBus: MessageEventBus by inject()

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // 1. 过滤目标 App
        val packageName = event.packageName?.toString() ?: return
        if (!ruleEngine.isTargetApp(packageName)) return

        // 2. 过滤事件类型
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) return

        // 3. 按规则解析界面
        val rootNode = rootInActiveWindow ?: return
        val messages = ruleEngine.parseMessages(packageName, rootNode)

        // 4. 发送到处理管道
        messages.forEach { eventBus.emit(RawMessageEvent(it)) }
    }

    override fun onInterrupt() {
        // 服务被系统中断，尝试自动恢复
        eventBus.emit(ServiceInterruptedEvent)
    }
}
```

**保活策略**（Android 后台限制越来越严格）：
- 前台服务（Foreground Service）+ 常驻通知
- 监听 `BOOT_COMPLETED` 开机自启
- 厂商白名单引导（小米/华为/OPPO/VIVO 的自启动管理）
- WorkManager 定时心跳检测，服务死亡自动重启
- **不采用**：双进程守护、JobScheduler 滥用等灰色手段（合规风险）

### 7.3 iOS 详细实现

```swift
// Notification Service Extension
class NotificationService: UNNotificationServiceExtension {

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        let content = request.content.mutableCopy() as! UNMutableNotificationContent

        // 1. 解析通知（微信通知格式：title=群名/发送人, body=消息内容）
        let rawMessage = parseWeChatNotification(content)

        // 2. 关键词匹配（共享代码库，与主 App 共用）
        let matcher = KeywordMatcher.shared
        if let result = matcher.match(rawMessage) {

            // 3. 写入 App Group 共享存储
            let storage = AppGroupStorage()
            storage.save(result)

            // 4. 修改通知内容（高亮关键词）
            content.body = formatWithHighlight(result)
            content.userInfo["matched"] = true
            content.userInfo["matchId"] = result.id
        }

        // 5. 必须在 30 秒内调用
        contentHandler(content)
    }
}
```

**App Group 数据流**：
```
[通知扩展进程]                    [主 App 进程]
      │                                 │
      ▼                                 ▼
┌─────────────────────────────────────────────┐
│      App Group Container (共享沙盒)          │
│  ┌───────────────────────────────────────┐  │
│  │  matched_messages.sqlite              │  │
│  │  keyword_rules.json                   │  │
│  │  config.plist                         │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

---

## 8. 数据模型设计

### 8.1 ER 图

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  KeywordRule    │         │ MonitoredGroup  │         │  MessageRecord  │
├─────────────────┤         ├─────────────────┤         ├─────────────────┤
│ id (PK)         │────┐    │ id (PK)         │────┐    │ id (PK)         │
│ keyword         │    │    │ app_id          │    │    │ group_id (FK)   │◄───┐
│ match_type      │    │    │ group_name      │    │    │ sender_name     │    │
│ priority        │    │    │ group_avatar    │    │    │ sender_id       │    │
│ scope_group_ids │◄───┼────┤ external_id     │    │    │ content         │    │
│ exclude_words   │    │    │ is_whitelist    │    │    │ content_html    │    │
│ notify_policy   │    │    │ is_blacklist    │    │    │ msg_type        │    │
│ enabled         │    │    │ monitor_enabled │    │    │ matched_keywords│────┘
│ created_at      │    │    │ last_active_at  │    │    │ match_score     │
│ updated_at      │    │    │ created_at      │    │    │ occurred_at     │
└─────────────────┘    │    └─────────────────┘    │    │ received_at     │
                       │                           │    │ is_read         │
                       │                           │    │ is_replied      │
                       │                           │    │ reply_content   │
                       │                           │    │ created_at      │
                       │                           │    └─────────────────┘
                       │                           │
                       │    ┌─────────────────┐    │    ┌─────────────────┐
                       │    │  ContactMapping │    │    │  QuickReply     │
                       │    ├─────────────────┤    │    ├─────────────────┤
                       └───►│ id (PK)         │    │    │ id (PK)         │
                            │ app_id          │    │    │ title           │
                            │ external_id     │    │    │ content         │
                            │ display_name    │    │    │ use_count       │
                            │ alias           │    │    │ enabled         │
                            │ is_friend       │    │    │ created_at      │
                            │ is_followed     │    │    └─────────────────┘
                            │ remark          │
                            └─────────────────┘
```

### 8.2 核心表结构 (SQL)

```sql
-- 消息记录表（核心表，高频写入）
CREATE TABLE message_records (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    app_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    sender_id TEXT,
    content TEXT NOT NULL,              -- 加密存储
    content_html TEXT,                  -- 带高亮标签的富文本
    msg_type INTEGER DEFAULT 0,         -- 0=文本 1=图片 2=语音 3=链接
    matched_keywords TEXT,              -- JSON array
    match_score REAL DEFAULT 0,
    occurred_at INTEGER NOT NULL,       -- 消息发生时间
    received_at INTEGER NOT NULL,       -- 本机接收时间
    is_read INTEGER DEFAULT 0,
    is_replied INTEGER DEFAULT 0,
    reply_content TEXT,
    fingerprint TEXT UNIQUE NOT NULL,   -- 去重指纹
    created_at INTEGER NOT NULL
);

-- 索引设计（按查询场景）
CREATE INDEX idx_msg_group_time ON message_records(group_id, occurred_at DESC);
CREATE INDEX idx_msg_received ON message_records(received_at DESC);
CREATE INDEX idx_msg_unread ON message_records(is_read, received_at DESC) WHERE is_read = 0;
CREATE INDEX idx_msg_fingerprint ON message_records(fingerprint);

-- 全文搜索（FTS5）
CREATE VIRTUAL TABLE message_fts USING fts5(
    content,
    sender_name,
    content='message_records',
    content_rowid='rowid'
);

-- 触发器保持 FTS 同步
CREATE TRIGGER msg_fts_insert AFTER INSERT ON message_records BEGIN
    INSERT INTO message_fts(rowid, content, sender_name)
    VALUES (new.rowid, new.content, new.sender_name);
END;
```

### 8.3 存储策略

- **热数据**（最近 7 天）：全字段 + FTS 索引，快速查询
- **温数据**（7-90 天）：保留核心字段，FTS 索引保留，详情压缩
- **冷数据**（90 天+）：归档到单独表或导出文件，默认清理
- **清理任务**：每日凌晨执行，LRU + 容量双阈值（默认最大 500MB）

---

## 9. 关键流程设计

### 9.1 端到端消息处理流程

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  监听源   │───►│  标准化   │───►│  去重    │───►│  匹配    │───►│  分发    │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                                                                      │
                          ┌───────────────────────────────────────────┤
                          │                                           │
                          ▼                                           ▼
                    ┌──────────┐                              ┌──────────┐
                    │  持久化   │                              │  通知    │
                    │  (DB)    │                              │  (本地)  │
                    └────┬─────┘                              └────┬─────┘
                         │                                         │
                         ▼                                         ▼
                    ┌──────────┐                              ┌──────────┐
                    │  UI 刷新  │                              │  用户点击 │
                    │  (BLoC)  │                              │  通知    │
                    └──────────┘                              └────┬─────┘
                                                                   │
                                                                   ▼
                                                            ┌──────────────┐
                                                            │  跳转执行器   │
                                                            │  (Android)   │
                                                            └──────┬───────┘
                                                                   │
                                              ┌────────────────────┼────────────────────┐
                                              │                    │                    │
                                              ▼                    ▼                    ▼
                                        ┌──────────┐        ┌──────────┐        ┌──────────┐
                                        │ 唤起微信  │───────►│ 进入群聊 │───────►│ @发送人  │
                                        └──────────┘        └──────────┘        └────┬─────┘
                                                                                     │
                                                                                     ▼
                                                                              ┌──────────┐
                                                                              │ 发送回复  │
                                                                              └──────────┘
```

### 9.2 状态机：单条消息的生命周期

```
                    ┌──────────┐
                    │ Captured │  监听引擎捕获原始事件
                    └────┬─────┘
                         │ parse
                         ▼
                    ┌──────────┐
              ┌─────│ Parsed   │  字段提取完成
              │     └────┬─────┘
              │          │ match
              │ dup      ▼
              │     ┌──────────┐     no hit     ┌──────────┐
              └────►│ Dropped  │◄───────────────│ Matched  │
                    └──────────┘                └────┬─────┘
                                                     │ hit
                                                     ▼
                                                ┌──────────┐
                                                │ Persisted│  写入数据库
                                                └────┬─────┘
                                                     │ notify
                                                     ▼
                                                ┌──────────┐
                                                │ Notified │  本地通知已发
                                                └────┬─────┘
                                                     │ user click
                                                     ▼
                                                ┌──────────┐
                                                │ Jumping  │  执行跳转
                                                └────┬─────┘
                                                     │ success/fail
                                                     ▼
                                                ┌──────────┐
                                                │ Replied  │  已回复（终态）
                                                └──────────┘
```

---

## 10. 质量属性设计

### 10.1 性能

| 场景 | 目标 | 手段 |
|------|------|------|
| 关键词匹配 | < 50ms/条 | AC 自动机 + 精确匹配快速通道 |
| 列表滑动 | 60fps | 分页加载（50条/页）+ 图片懒加载 |
| 启动时间 | 冷启动 < 2s | 延迟初始化 + 首屏骨架屏 |
| 内存占用 | < 150MB | 消息分页 + Bitmap 池 + 泄漏检测 |

### 10.2 可靠性

- **崩溃防护**：关键服务（Accessibility、Notification Listener）崩溃自动重启
- **数据不丢**：消息先入内存队列，持久化成功才标记完成
- **降级策略**：监听失效时通知用户，提供"修复"入口引导重新授权

### 10.3 安全与隐私

- **传输加密**：云端通信 TLS 1.3 + 证书固定（Certificate Pinning）
- **存储加密**：SQLCipher AES-256，密钥从 Android Keystore / iOS Keychain 派生
- **权限最小化**：只申请必需权限，敏感权限（无障碍、通知）单独引导并说明用途
- **隐私政策**：明确告知采集范围、用途、存储位置，提供数据导出与删除

### 10.4 合规风险（重要）

| 风险 | 等级 | 缓解措施 |
|------|------|----------|
| 微信用户协议禁止第三方客户端 | **高** | 定位"辅助工具"而非"客户端"，不模拟登录、不发送协议数据 |
| 无障碍服务滥用被 Google Play 下架 | **高** | 申报合理使用场景（辅助功能），上架前合规审查 |
| 群聊内容涉及他人隐私 | **中** | 本地加密、默认不上云、提供自动清理 |
| 关键词监控可能被用于不当目的 | **中** | 用户协议禁止违法用途、关键词审计日志 |

### 10.5 可观测性

- **本地日志**：关键事件（监听启动/停止、匹配命中、跳转执行）落盘，支持导出
- **匿名统计**（可选）：功能使用率、崩溃率、性能指标，不含消息内容
- **远程配置**：关键词匹配参数、降级开关、规则版本可远程调整

---

## 11. 长期演进规划

### 11.1 路线图（24 个月）

```
Phase 1 (M1-M3): MVP 验证期
├── 平台: 仅 Android
├── 功能: 微信监听 + 关键词匹配 + 本地提醒 + 基础跳转
├── 目标: 100 个种子用户，验证核心价值
└── 关键指标: 匹配准确率 > 95%, 崩溃率 < 0.5%

Phase 2 (M4-M6): 体验优化期
├── 平台: Android 完整 + iOS 阉割版
├── 功能: 规则热更新、悬浮球、快捷回复、历史统计
├── 目标: 1,000 活跃用户，iOS 验证可行性
└── 关键指标: 次日留存 > 40%, 周活/月活 > 60%

Phase 3 (M7-M12): 智能化增强期
├── 功能: 语义匹配（本地小模型）、图片消息 OCR、语音转文字
│        多 App 支持（QQ/钉钉/企微）、数据看板
├── 目标: 10,000 用户，建立口碑
└── 关键指标: NPS > 40, 语义匹配准确率 > 85%

Phase 4 (M13-M18): 平台化扩展期
├── 功能: 云端同步（E2EE）、多设备、团队协作
│        开放 API（第三方集成）、自动化工作流
├── 目标: 50,000 用户，探索商业化
└── 关键指标: 付费转化率 > 5%, 团队版 ARPU > ¥50/月

Phase 5 (M19-M24): 生态化建设期
├── 功能: 插件市场（第三方关键词包、行业模板）
│        垂直行业解决方案（物流/电商/招聘/房产）
│        SaaS 管理后台（企业客户）
├── 目标: 200,000 用户，商业化跑通
└── 关键指标: MRR > ¥100万, 企业客户 > 100家
```

### 11.2 技术演进

```
当前 (V1)                          V2-V3                            V4-V5
─────────                          ──────                           ─────
Flutter 单体                       模块化拆分                        插件化架构
  │                                │                                 │
  ├─ 核心模块                       ├─ 匹配引擎插件                    ├─ 行业插件包
  ├─ 平台适配层                     ├─ OCR 插件                       ├─ 第三方集成
  └─ 本地存储                       ├─ 语义匹配插件                    ├─ 工作流引擎
                                    └─ 云端同步模块                    └─ SaaS 后台

手动规则                           半自动规则                         AI 驱动
─────────                          ─────────                         ────────
人工编写微信适配规则                自动检测 UI 变更 + 人工确认           机器学习预测 UI 结构
人工测试关键词                     关键词推荐（基于历史）               智能场景识别（自动推荐规则）
```

### 11.3 商业化路径

| 阶段 | 模式 | 定价参考 |
|------|------|----------|
| V1-V2 | 免费增值 | 基础功能免费，高级功能（多关键词、多群）内购解锁 |
| V3 | 订阅制 | 个人版 ¥15/月，专业版 ¥30/月（语义匹配、多设备） |
| V4 | 团队版 | ¥99/人/月，共享关键词库、团队看板、API 访问 |
| V5 | 企业版 | 定制报价，私有化部署、行业解决方案、SLA 保障 |

---

## 12. 风险与缓解措施

### 12.1 技术风险

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| 微信大版本更新导致监听失效 | **高** | 高 | 规则热更新机制 + 7×24 监控 + 快速响应 SOP（< 4小时） |
| Android 厂商杀后台 | **高** | 中 | 前台服务 + 厂商白名单引导 + 用户教育 |
| iOS 功能阉割影响口碑 | 中 | 中 | 明确产品定位"iOS 为提醒工具"，不承诺跳转功能 |
| 无障碍权限被滥用导致下架 | 低 | **极高** | 严格合规审查 + 备用上架渠道（官网 APK） |

### 12.2 合规风险

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| 微信官方投诉/诉讼 | 中 | **极高** | 法律意见书 + 不碰协议逆向 + 定位"辅助工具" |
| 个人信息保护法合规 | 中 | 高 | 数据本地化 + 隐私影响评估（PIA）+ 合规审计 |
| 关键词监控被用于违法用途 | 低 | 高 | 用户协议禁止 + 关键词审计 + 举报机制 |

### 12.3 业务风险

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| 微信推出官方类似功能 | 中 | **极高** | 差异化定位（垂直行业深度定制）+ 快速转型能力 |
| 目标用户付费意愿低 | 中 | 高 | MVP 阶段验证付费 + 探索 B 端场景 |
| 竞品抄袭 | **高** | 中 | 技术护城河（匹配引擎、规则库）+ 社区运营 |

---

## 附录 A: 推荐技术栈汇总

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 跨平台框架 | Flutter 3.x | UI + 业务逻辑 |
| 状态管理 | Riverpod / BLoC | 响应式数据流 |
| 本地数据库 | Drift (SQLite) + SQLCipher | 类型安全 + 加密 |
| 依赖注入 | get_it + injectable | 解耦与测试 |
| 网络 | Dio + Retrofit | HTTP 客户端 |
| 序列化 | json_serializable / freezed | 数据类生成 |
| Android 原生 | Kotlin + Coroutines + Flow | 监听引擎 |
| iOS 原生 | Swift + Combine | 通知扩展 |
| 后台任务 | WorkManager (A) / BGTaskScheduler (iOS) | 定时任务 |
| 崩溃监控 | Firebase Crashlytics / Sentry | 稳定性监控 |
| 热更新 | Shorebird (Flutter) / 自研规则下发 | 紧急修复 |

---

## 附录 B: 项目目录结构建议

```
message_assistant/
├── lib/                          # Flutter 主代码
│   ├── main.dart
│   ├── app/                      # 应用层（路由、主题、依赖注入）
│   ├── presentation/             # 表示层（页面、组件、BLoC）
│   │   ├── pages/
│   │   │   ├── message_list/
│   │   │   ├── keyword_config/
│   │   │   ├── history/
│   │   │   └── settings/
│   │   └── widgets/
│   ├── domain/                   # 领域层（纯业务逻辑）
│   │   ├── entities/
│   │   ├── repositories/         # 抽象接口（端口）
│   │   ├── services/
│   │   └── value_objects/
│   ├── infrastructure/           # 基础设施层（适配器）
│   │   ├── database/
│   │   ├── platform_channels/
│   │   ├── network/
│   │   └── storage/
│   └── core/                     # 通用工具（常量、扩展、错误）
├── android/                      # Android 原生模块
│   └── app/src/main/kotlin/
│       ├── accessibility/        # 无障碍监听
│       ├── notification/         # 通知监听
│       ├── launcher/             # 跳转执行
│       ├── floating/             # 悬浮球
│       └── rules/                # 规则引擎
├── ios/                          # iOS 原生模块
│   ├── Runner/
│   ├── NotificationExtension/    # 通知服务扩展
│   └── Shared/                   # App Group 共享代码
├── packages/                     # 内部包（可选拆分）
│   ├── keyword_engine/           # 关键词匹配引擎（纯 Dart）
│   ├── message_models/           # 数据模型
│   └── rule_parser/              # 规则解析器
├── assets/                       # 资源文件
│   ├── rules/                    # 内置规则包
│   └── templates/                # 快捷回复模板
├── test/                         # 测试
│   ├── unit/
│   ├── widget/
│   └── integration/
└── docs/                         # 文档（本文件所在）
    ├── architecture.md
    ├── adr/                      # 架构决策记录
    └── api/                      # 接口文档
```

---

## 附录 C: 立即行动清单

**第一周（技术验证）**：
1. [ ] 搭建 Flutter + Platform Channel 工程骨架
2. [ ] 实现 Android AccessibilityService 监听微信首页（Hello World 级别）
3. [ ] 验证规则引擎可行性（用硬编码规则解析微信界面）
4. [ ] 搭建 SQLite 数据库 + 基础 CRUD

**第二周（核心闭环）**：
5. [ ] 实现关键词匹配引擎（精确 + 子串匹配）
6. [ ] 打通"监听 → 匹配 → 本地通知"全流程
7. [ ] 实现基础消息列表 UI（参考截图布局）
8. [ ] 验证 Android 跳转微信功能

**第三周（iOS 验证）**：
9. [ ] 实现 Notification Service Extension 拦截微信通知
10. [ ] 验证 App Group 数据共享
11. [ ] 评估 iOS 功能阉割范围，更新产品定位文档

**第四周（打磨）**：
12. [ ] 完善权限引导流程（无障碍、通知、悬浮窗）
13. [ ] 实现消息去重与批量写入
14. [ ] 编写 ADR-001~005 正式版本，组织技术评审

---

> **架构师签名**: Software Architect
> **下次评审**: 2026-08-13（两周后）
> **变更记录**: v1.0 初稿创建

# 自动回复功能 — 设计规格（AccessibilityService 自动跳转回复）

> **文档版本**: v1.0
> **创建日期**: 2026-07-31
> **状态**: Approved（用户已逐节确认）
> **上游架构**: `docs/architecture.md` v1.0（ADR-002 主引擎、F6 跳转、F7 @发送人）
> **本次范围**: P2 增量 —— 详情页"自动回复"全链路（唤起微信→搜索群→进群→@发送人→发送）
> **目标设备**: 华为 Android 12 (API 31) + 微信 8.0.76 (versionCode 3141)

---

## 0. 背景与决策记录

### 0.1 上游关系

本规格是 `docs/architecture.md` Phase 2 体验优化期的**首个设备依赖增量**。MVP（`2026-07-30-message-assistant-mvp-design.md`）已完成并经用户真机验证：微信群通知监听 + 关键词匹配 + 本地提醒可跑通，但 F6 跳转仅"唤起微信主页"，F7 自动@发送人未实现。本增量补齐这两个核心缺口。

### 0.2 本次范围决策（用户确认）

| 决策点 | 选择 | 理由 |
|--------|------|------|
| **AccessibilityService 定位** | **执行器**（不做采集） | 消息监听仍走已验证的 NotificationListener；AccessibilityService 只在用户触发回复时操作微信。避免双引擎融合复杂度。 |
| **定位群聊** | 搜索群名进群 | 微信首页→搜索→群名→点结果。最通用，不依赖会话列表顺序。 |
| **@发送人** | 文本@（不触发联系人选择） | 输入框注入"@发送人 回复"。简单、快、不易碎。货运抢单场景文本@够用（虽非魔法@，发送人不被高亮提醒）。 |
| **失败处理** | 分步重试 + 降级手动 | 每步超时 3s + 最多 3 次（1首试+2重试）；失败则复制到剪贴板 + Toast，用户手动。 |
| **回复内容** | 单一默认回复 | 默认"接单"，设置页可改。覆盖抢单主场景。 |
| **触发方式** | 详情页主动点击 | 仅用户主动触发，**绝不后台自动回复**（合规红线）。 |

### 0.3 目标设备信息（实施期校准基准）

- 设备：华为，Android 12（API 31）
- 微信：8.0.76，versionCode 3141，targetSdk 34
- 设备已授权 USB 调试，App 已安装并验证 MVP 可用

### 0.4 环境约束

| 事项 | 状态 | 影响 |
|------|------|------|
| 开发机 Flutter/Kotlin 工具链 | ✅ 已搭好（MVP 期间） | 单测/编译可跑 |
| 真机已连接 | ✅ 华为 Android 12 | **节点校准与端到端可验证**（MVP 时无设备，现可验证） |
| 微信版本 | 8.0.76 | 规则针对此版本；改版需重校准 |

---

## 1. 功能范围

### 1.1 本次实现

| 功能 | 实现 | 架构来源 |
|------|------|---------|
| F6 自动跳转到目标群 | AccessibilityService 模拟：微信首页→搜索→群名→进群 | F6 升级 |
| F7 自动@发送人 | 输入框注入"@发送人 默认回复"（文本@） | F7 |
| 自动发送 | 定位发送按钮，模拟点击 | 新增 |
| 默认回复文本 | 设置页配置，默认"接单" | 新增 |
| 执行可观测 | 详情页进度面板，6 步实时状态（进行中/成功/失败/重试） | 新增 |
| 失败降级 | 分步重试（3s/3次）→ 失败复制+Toast，用户手动 | 架构 6.3 降级 |
| 无障碍权限引导 | 设置页状态行 + 去开启；首次触发时引导 | 新增 |

### 1.2 本次明确不做（防范围蔓延）

- ❌ 用 AccessibilityService 做**消息采集**（监听仍走 NotificationListener）
- ❌ 魔法@（触发联系人选择菜单）——易碎，文本@够用
- ❌ 多话术选择、每次手动输入回复——单一默认回复
- ❌ 悬浮球触发（F11）、**后台自动回复**（合规红线）
- ❌ 规则热更新服务器下发（ADR-005 完整版）——微信 UI 规则**本地硬编码**针对 8.0.76

### 1.3 合规红线（必须强调）

- **绝不后台静默自动回复**——必须有用户在 App 内主动点击触发。后台自动回复会被微信判机器人，封号风险高，违反用户预期。
- AccessibilityService 只在用户主动触发回复时操作微信，**不持续监听/采集**微信界面。
- `packageNames` 限定只对微信生效，不窥探其他 App。
- 操作日志本地落盘，便于排查。

---

## 2. 技术架构与执行引擎

### 2.1 核心思路

微信 UI 是节点树（AccessibilityNodeInfo）。自动回复本质：**按固定路径找节点 → 执行动作（点击/输入） → 等待界面变化 → 找下一节点**。

```
AutoReplyRequest { groupName, senderName, replyText }
   ↓
AutoReplyEngine（状态机驱动）
   ↓  读
WeChatUIMatcher（声明式规则：针对 8.0.76，定位各节点）
   ↓  调
AccessibilityService API（findAccessibilityNodeInfosByText/byViewId, performAction）
```

### 2.2 执行状态机

线性状态序列，每个状态对应微信界面一步：
```
IDLE
 ↓ 触发
LAUNCHING_WECHAT          唤起微信主界面（Intent）
 ↓ 检测到微信首页
OPENING_SEARCH            点击首页搜索入口
 ↓ 检测到搜索页
INPUTTING_GROUP_NAME      搜索框输入群名
 ↓ 检测到结果列表
ENTERING_GROUP            点击匹配的群结果
 ↓ 检测到群聊界面（输入框出现）
INPUTTING_REPLY           输入框注入 "@发送人 回复"
 ↓ 文本已填入
SENDING                   点击发送按钮
 ↓ 输入框清空（消息已发）
DONE
```

**每步统一执行模型**：
```
进入状态 S:
  1. 轮询等待目标节点出现（超时 3s，每 200ms 查一次）
  2. 节点出现 → 执行动作（点击/输入）
  3. 失败 → 重试（最多 3 次 = 1 首试 + 2 重试）
  4. 仍失败 → 整条链中止，状态 → FAILED，降级
  5. 成功 → 进入下一状态
```

### 2.3 WeChatUIMatcher —— 声明式规则（针对 8.0.76，节点规则需真机校准）

把"如何定位每个节点"封装为纯函数式匹配器。**最易碎部分**——微信改版改这里。MVP 本地硬编码，结构为 ADR-005 热更新留接口。

```kotlin
object WeChatUIMatcher {
    fun findSearchEntry(root): AccessibilityNodeInfo?      // 首页搜索入口
    fun findSearchInput(root): AccessibilityNodeInfo?      // 搜索页输入框
    fun findGroupResult(root, groupName): AccessibilityNodeInfo?  // 群聊结果项
    fun findChatInput(root): AccessibilityNodeInfo?        // 群聊输入框
    fun findSendButton(root): AccessibilityNodeInfo?       // 发送按钮
}
```

**【头号风险】**：真实节点定位逻辑（view-id / text / 层级）必须真机实测确定（微信 8.0.76 对节点 id 做了混淆，如 `bkk`、`f4a` 无意义 id，每版本变）。实施期通过 adb dump 校准（见 §5.2）。

**匹配策略**（每 findXxx 按可靠性多策略兜底）：
1. by view-id（最稳，需实测真实 id）
2. by text/content-desc（"发消息"等固定文案）
3. 遍历找特定类型节点（如 EditText）
取第一个命中。

### 2.4 与现有架构的集成

新增原生模块，通过新通道暴露给 Flutter：
```
[Flutter 详情页] 点"自动回复"
   ↓ MethodChannel "message_assistant/autoreply" → startAutoReply(request)
[AutoReplyAccessibilityService]
   ↓
[AutoReplyEngine 状态机] ↔ [WeChatUIMatcher 规则]
   ↓ 每步状态
[EventChannel "message_assistant/autoreply_progress"] → Flutter 进度 UI
   ↓ 完成/失败
[结果回传] → 详情页显示，失败则复制到剪贴板
```

**新增通道**：
- MethodChannel `"message_assistant/autoreply"`：`startAutoReply`(groupName/senderName/replyText) → 触发后立即返回（不等执行完）；`cancelAutoReply`
- EventChannel `"message_assistant/autoreply_progress"`：推每步进度 `{step, status, attempt, errorMessage?}`。**终结信号**：任一步的 `status=failed`（且 attempt=3）即为整条链失败的终结；最后一步 `SENDING` 的 `status=success` 即为整体成功终结。Gateway（infra 层）据此聚合：当收到 success-on-SENDING → 产出 `AutoReplyOutcome(success)`；收到任一 failed（attempt=3）→ 产出 `AutoReplyOutcome(failed, failedAtStep=该步)` 并停止订阅。`cancelled` 由 cancelAutoReply 触发后 Gateway 主动产出。

**现有通道扩展**：
- MethodChannel `"message_assistant/control"` 加：`isAccessibilityEnabled`、`openAccessibilitySettings`

---

## 3. 领域层与 Flutter 侧

### 3.1 领域实体（domain 新增，纯 Dart）

```dart
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

### 3.2 端口与编排

```dart
// domain/repositories/i_auto_reply_gateway.dart（端口）
abstract class IAutoReplyGateway {
  Future<AutoReplyOutcome> execute(AutoReplyRequest request);
  Stream<AutoReplyProgress> get progress;
  Future<void> cancel();
}
```

```dart
// domain/services/auto_reply_executor.dart
class AutoReplyExecutor {
  final IAutoReplyGateway _gateway;
  final IMessageRepository _messageRepo;
  // execute(request): 监听 gateway.progress 聚合为 outcome；
  //   成功 markReplied(messageId, replyText)；失败返回 outcome 让 UI 降级
}
```
领域层只编排不碰微信，可单测（mock 网关）。

### 3.3 基础设施层

```dart
// infrastructure/platform/auto_reply_channel.dart
class AutoReplyGateway implements IAutoReplyGateway {
  // MethodChannel "message_assistant/autoreply" + EventChannel "..._progress"
  // execute(): 调 startAutoReply，订阅 progress 流，等终结事件返回 outcome
  // cancel(): 调 cancelAutoReply
}
```

### 3.4 PlatformActions 扩展

现有 `PlatformActions` 加：
```dart
Future<bool> isAccessibilityEnabled();
Future<void> openAccessibilitySettings();
```
走现有 control MethodChannel。

### 3.5 Providers（Riverpod）

```dart
// 默认回复文本，持久化到 IConfigStore（见下，需扩展该端口）
final defaultReplyTextProvider = StateNotifierProvider<DefaultReplyTextNotifier, String>(
  (ref) => DefaultReplyTextNotifier(ref.read(configStoreProvider)));
final autoReplyGatewayProvider = Provider<IAutoReplyGateway>((ref) => AutoReplyGateway());
final autoReplyExecutorProvider = Provider((ref) => AutoReplyExecutor(
  gateway: ref.read(autoReplyGatewayProvider), messageRepo: ref.read(messageRepoProvider),
));
final autoReplyProgressProvider = StateProvider<AutoReplyOutcome?>((ref) => null);
```

**IConfigStore 端口需扩展**（MVP 只有 QuietHours/TargetApps）：新增两个方法：
```dart
abstract class IConfigStore {
  // ...现有方法...
  Future<Either<Failure, String>> getDefaultReplyText();        // 默认 "接单"
  Future<Either<Failure, void>> setDefaultReplyText(String text);
}
```
现有 `_MemoryConfigStore`（providers.dart 里的 MVP 占位实现）同步加这两个方法的内存实现；DriftConfigStore 持久化留后续（与 quietHours 同机制）。`DefaultReplyTextNotifier` 在初始化时从 ConfigStore 读取，setValue 时写回。

### 3.6 详情页 UI 改造

底部按钮区：
- 保留"复制消息""标记已回复"
- "复制并打开微信"→ 降级为次级按钮
- 新增主按钮"自动回复"（FilledButton，强调）

点击"自动回复"：
1. 检查无障碍授权 → 未授权引导
2. 已授权 → 构造 AutoReplyRequest（groupName=消息群名、senderName、replyText=默认回复）
3. 调 executor.execute()，订阅 progressProvider
4. UI 显示进度面板（6 步图标，每步 spinner/✓/✗/重试）
5. 成功 → SnackBar"已自动回复" + 标记 isReplied
6. 失败 → 复制回复文本 + SnackBar"自动回复失败，已复制，请手动"

进度面板示例：
```
自动回复进度
✓ 唤起微信
✓ 打开搜索
✓ 输入群名
⏳ 进入群聊…  (重试 2/2)
○ 输入回复
○ 发送
```

### 3.7 设置页改造

- 新增"无障碍服务"行（与"通知监听"并列）：状态 + 去开启
- 新增"默认回复文本"输入框（默认"接单"，可改）

---

## 4. Android 原生实现

### 4.1 组件总览

```
AutoReplyAccessibilityService (AccessibilityService)
  • onAccessibilityEvent: 不采集，仅 engine 运行时作"界面已变"信号
  • 持有 AutoReplyEngine；暴露静态引用供 plugin 调用
AutoReplyEngine (状态机驱动器)
  • execute(request): 顺序执行状态机
  • 每步轮询节点→动作→等待→下一步；超时/重试/降级
  • 通过 progress sink 上报
WeChatUIMatcher (声明式规则，针对 8.0.76，【节点规则需真机校准】)
AutoReplyPlugin (FlutterPlugin)
  • MethodChannel "message_assistant/autoreply" + EventChannel "..._progress"
AppLauncher 扩展
  • isAccessibilityEnabled / openAccessibilitySettings（加到 control 通道）
```

### 4.2 AutoReplyEngine 状态机（详细）

```kotlin
class AutoReplyEngine(
    private val service: AccessibilityService,
    private val matcher: WeChatUIMatcher,
    private val progressSink: (AutoReplyProgress) -> Unit,
) {
    fun execute(request: AutoReplyRequest) {
        scope.launch {
            val result = runStep(LAUNCHING)      { launchWechat() }
                ?.let { runStep(OPENING_SEARCH)  { openSearch() } }
                ?.let { runStep(INPUTTING_GROUP) { inputGroupName(request.groupName) } }
                ?.let { runStep(ENTERING_GROUP)  { enterGroup(request.groupName) } }
                ?.let { runStep(INPUTTING_REPLY) { inputReply("@${request.senderName} ${request.replyText}") } }
                ?.let { runStep(SENDING)         { clickSend() } }
            reportFinal(result != null)
        }
    }

    // 单步：超时 3s + 最多 3 次（1 首试 + 2 重试）
    private suspend fun runStep(step, action): Boolean? {
        repeat(3) { attempt ->
            reportProgress(step, if (attempt == 0) IN_PROGRESS else RETRYING, attempt + 1)
            val ok = withTimeoutOrNull(3000) { action() }
            if (ok) { reportProgress(step, SUCCESS, attempt + 1); return true }
        }
        reportProgress(step, FAILED, 3, "步骤失败")
        return null  // 短路中止整条链
    }
}
```

- Coroutine 顺序执行，`withTimeoutOrNull` 单步超时不阻塞主线程
- 每步最多 3 次，失败 null 短路
- progress 通过 sink 实时上报

### 4.3 输入文本特殊处理

优先 `ACTION_SET_TEXT`（API 21+，最可靠），失败 fallback `ACTION_PASTE`（先复制到剪贴板）：
```kotlin
fun setText(node, text): Boolean {
    val args = Bundle().apply { putCharSequence(ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text) }
    return node.performAction(AccessibilityNode.ACTION_SET_TEXT, args)
}
```
输入前 sanitize（去换行等特殊字符）。

### 4.4 AndroidManifest + 权限

```xml
<service
    android:name=".AutoReplyAccessibilityService"
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

`res/xml/auto_reply_accessibility_config.xml`：
```xml
<accessibility-service
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault|flagRetrieveInteractiveWindows"
    android:canRetrieveWindowContent="true"
    android:canPerformGestures="false"
    android:packageNames="com.tencent.mm" />
```
**关键**：`packageNames="com.tencent.mm"` 限定只对微信生效——减少干扰 + 降低合规风险。

### 4.5 onAccessibilityEvent 角色

本增量 AccessibilityService 不做持续采集（消息监听仍走 NotificationListener）：
```kotlin
override fun onAccessibilityEvent(event) {
    // 仅 engine 运行时，用 event 作"界面已变，可查下一节点"信号
    // 不解析/存储任何界面内容
    engine?.onWindowChanged(event)
}
```

### 4.6 生命周期与降级

- engine 执行时用户切走（中断）→ `onInterrupt` / 检测当前 App 非微信 → 中止 + 报失败
- 完成后 engine 置空，service 空闲
- App 被杀时 service 仍存活（无障碍服务独立进程），engine 引用丢失——下次进 App 重建

---

## 5. 测试、验证策略与风险

### 5.1 验证矩阵（诚实分级）

| 层 | 内容 | 工具 | 我能验证？ | 证据 |
|----|------|------|-----------|------|
| 领域层 | AutoReplyExecutor 编排（mock 网关，成功/失败/取消/降级） | flutter test | ✅ | 测试输出 |
| 基础设施层 | AutoReplyGateway 通道映射（progress→实体） | flutter test（@visibleForTesting） | ✅ | 测试输出 |
| Widget 层 | 详情页进度面板、按钮、失败 SnackBar | flutter test（mock executor） | ✅ | 测试输出 |
| Kotlin：状态机 | AutoReplyEngine 重试/超时/短路（mock matcher+action） | JUnit | ✅ | 测试输出 |
| Kotlin：匹配逻辑 | WeChatUIMatcher 在假节点树匹配（纯函数化） | JUnit | ✅ | 测试输出 |
| **Kotlin：真实节点定位** | WeChatUIMatcher 在微信8.0.76 实际节点 findXxx | **adb dump 真机** | ⚠️ 能 dump 验证节点存在，**完整点击链路需真机交互** | dump 报告 |
| **端到端自动回复** | 点"自动回复"→微信真自动进群@发送 | **真机+微信** | ❌ | 验证清单（用户执行） |

### 5.2 WeChatUIMatcher 真机校准流程（实施期我执行）

降低头号风险的关键步骤：
1. **adb dump 各界面节点树**：
   - 微信首页 → `adb shell uiautomator dump` → 分析搜索入口
   - 搜索页 → 分析搜索框
   - 搜索结果 → 分析群聊项
   - 群聊页 → 分析输入框 + 发送按钮
2. **填入规则**：实测 view-id/text/层级填入 WeChatUIMatcher 各 findXxx
3. **单测验证匹配逻辑**：构造假节点树跑 JUnit
4. **dump 复核**：再次 dump 验证 findXxx 在真实树命中

此步把"规则正确性"验证到极限，但点击是否真触发、时序是否对仍需真机跑。

### 5.3 设备验证清单（追加到 docs/verification-checklist.md）

- [ ] 设置页"无障碍服务"状态显示，"去开启"跳系统授权页
- [ ] 授权"消息助手自动回复"服务
- [ ] 详情页出现"自动回复"主按钮
- [ ] 点"自动回复"→ 微信唤起→搜索→输入群名→进群→输入"@发送人 接单"→发送
- [ ] 进度面板实时显示各步状态
- [ ] 成功 → 标记已回复 + SnackBar"已自动回复"
- [ ] 群里确实收到"@发送人 接单"
- [ ] 失败场景：执行中切走微信 → 中止 + 复制 + SnackBar
- [ ] 未授权时点"自动回复"→ 引导授权（不执行）
- [ ] 默认回复改为"已发车"后 → 用新文本

### 5.4 风险登记

| 风险 | 等级 | 缓解 |
|------|------|------|
| **微信8.0.76 节点规则失效**（改版/混淆id变） | **极高** | 规则集中 WeChatUIMatcher 单文件；实施期 dump 校准；spec 标注"改版需重校准" |
| 微信搜索群名匹配不到/重名 | 高 | 取第一个结果项；失败降级手动；后续加群名精确度校验 |
| 华为 EMUI/HarmonyOS 无障碍服务被系统限制 | 中 | 引导加华为无障碍白名单；失败提示检查 |
| @发送人文本含特殊字符致输入异常 | 中 | 输入前 sanitize；用 SET_TEXT |
| 自动回复被微信判机器人 | 中 | **绝不后台自动回复**，仅主动触发；频率用户控制 |
| AccessibilityService 与 NotificationListener 共存协调 | 低 | 两者独立 service 互不依赖；engine 仅触发时活跃 |

### 5.5 实施顺序（writing-plans 细化）

1. 领域层（AutoReplyRequest/Progress/Outcome + Executor + 端口）+ 单测
2. 基础设施层（AutoReplyGateway 通道映射）+ 单测
3. **真机校准**：adb dump 微信节点树，分析
4. 原生层（WeChatUIMatcher 填规则 + AutoReplyEngine + AutoReplyAccessibilityService + Plugin + Manifest）+ JUnit
5. Flutter UI（详情页进度面板、设置页无障碍/默认回复）+ Widget 测试
6. 集成 + APK 编译 + 真机端到端验证清单

---

## 附录：与 MVP 设计的协调

- **解析逻辑仍只在 Kotlin**：本增量不改变 MVP 的"NotificationParser 解析通知、EventChannel 传结构化字段"协调。AccessibilityService 不做采集，无新解析路径。
- **通道新增不冲突**：新增 `message_assistant/autoreply` 与 `..._progress`，与现有 `notification`/`control` 并列。
- **PlatformActions 扩展不破坏现有**：新增 isAccessibilityEnabled/openAccessibilitySettings 两个方法，现有方法不变。
- **领域隔离不变**：新增领域实体/服务/端口仍纯 Dart，受 domain_lint 强制。

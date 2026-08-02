# 微信 8.0.76 AccessibilityService 防护 — 可行性发现记录

> **日期**: 2026-07-31
> **状态**: 已验证的事实结论（非推测）
> **背景**: 本想用 AccessibilityService 实现自动回复（唤起微信→搜索群→进群→@发送人→发送），需先 dump 微信节点树校准 UI 规则。

---

## 结论

**微信 8.0.76 在华为 Android 12 设备上主动屏蔽了 AccessibilityService 的子节点读取。** 基于节点查找+点击的自动化方案不可行。

## 补充验证：群聊界面同样屏蔽（2026-08-01）

首版发现文档只验证了首页/搜索页。后续针对**群聊界面（ChattingMainUI）**做了精准二次验证，结论一致——屏蔽是全局的，不限于首页：

- 用户跳进微信群聊（用 contentIntent）→ 点输入框聚焦、键盘弹起 → ChatProbe 探测
- 结果（多次一致）：`childCount=1`（根只有一个空子节点）、`focusInput: ?--`（**findFocus 焦点路径也拿不到输入框**）、`EditText count=0`、`发送 nodes=0`
- 即使用户主动聚焦输入框，`findFocus(FOCUS_INPUT)` 仍返回空 → 微信连"焦点节点"也屏蔽
- **自动发送（注入文本+点发送按钮）不可行**，与首页结论一致，现已彻底确认

→ 无论是"树遍历找节点"还是"findFocus 焦点路径"，微信 8.0.76 都屏蔽。在没有 Root/逆向的前提下，无任何自动操作微信群聊界面的路径。

## 实验证据（对照实验，同一 service/同一设备/同一运行）

| 目标 App | AccessibilityService `rootInActiveWindow` 结果 |
|---------|-----------------------------------------------|
| 华为应用市场（com.huawei.appmarket，普通 App） | ✅ **完整节点树**：childCount=5，可见 ImageView/LinearLayout/AutoCompleteTextView/RecyclerView 的完整层级、text、content-desc、bounds、可点击/可编辑标志 |
| **微信 8.0.76（com.tencent.mm）** | ❌ **空根节点**：childCount=0，仅返回 packageName 根，无任何子节点（"(empty root — no children visible)"） |

关键控制变量：
- service 正常 `onServiceConnected`（logcat 有 "connected" 日志）
- service 在系统 `enabled_accessibility_services` 授权列表内
- service 进程持续存活（与 App 同进程，pid 稳定）
- **事件正常投递**：微信前台时 `onAccessibilityEvent` 确实触发（eventType=2048 TYPE_WINDOW_CONTENT_CHANGED、32 TYPE_WINDOW_STATE_CHANGED 都有）
- `rootInActiveWindow` 返回**非 null**（一个带正确 packageName 的根），但 `childCount == 0`

→ 即：不是 service 没连上、不是事件没投递、不是配置问题，而是**微信对子节点读取的主动屏蔽**。

## 其他被排除的路径

- ❌ `adb shell uiautomator dump`：微信 secure flag，返回空树（399 字节，只有一个空根节点）
- ❌ `dumpsys view hierarchy`：只拿到桌面 launcher 视图，非微信内部
- ❌ 微信未在 manifest 声明明显的 accessibility 防护 flag，防护是运行时行为

## 合规红线决定不碰

以下路径技术上可能突破防护，但**违反架构文档红线，绝对不做**：
- Root + Xposed/EdXposed hook 微信进程
- 协议逆向 / 解密微信数据库
- 注入 / Frida 动态插桩

这些会触发《个人信息保护法》风险 + 微信用户协议违反 + 封号风险，不可接受。

## 影响

- **自动回复全链路（F6 自动进群 + F7 自动@发送人）在微信 8.0.76 上不可行**。
- 已完成的 Phase A（领域层：AutoReply 实体/端口/Executor）和 Phase B（基础设施：AutoReplyGateway 通道映射 + providers）代码**保留**——它们不依赖微信节点，是可复用的编排框架，未来若微信防护变化或换其他 IM（QQ/钉钉未屏蔽时）可启用。
- 当前转向"智能复制 + 快捷话术"：不依赖节点操作，用 NotificationListener（已验证可用）+ 剪贴板 + 唤起微信。

## 复测建议

- 微信版本升级时（如 8.0.8x+），可重跑本文档的对照实验复测：若某版本微信不再屏蔽（如腾讯放宽防护），可重启自动回复方向。
- 不同 IM（QQ、企业微信、钉钉）的防护程度不同，未来若支持多 App 可分别复测。

---

## 补充验证：RPA（手势派发+截屏）可行！（2026-08-01）

虽然微信屏蔽了 AccessibilityService 的**节点读取**（rootInActiveWindow 空根），但另外两项能力**未被屏蔽**，这是 RPA 自动回复的可行基础：

### 地基1：dispatchGesture（手势派发）对微信有效 ✅
- 测试：GestureProbeAccessibilityService（canPerformGestures=true）在微信群聊界面 dispatchGesture 点击坐标 (540,2200)
- 结果：`dispatchGesture returned=true` + `tap COMPLETED`（手势完成，未被 cancel）
- 结论：微信**没有屏蔽手势派发**——可以模拟人手点击屏幕任意坐标。

### 地基2：takeScreenshot（截屏）对微信有效 ✅
- 测试：同一 service（canTakeScreenshot=true，API 30+）在微信群聊界面 takeScreenshot
- 结果：`takeScreenshot SUCCESS: width=1080 height=2400 colorSpace=sRGB`（拿到完整微信画面）
- 结论：微信的 secure flag **没有屏蔽 accessibility 截屏**（与 uiautomator dump 被屏蔽不同）。

### RPA 方案因此成立
1. 截屏（takeScreenshot）→ 拿到微信画面 ✅
2. 图像识别（纯 Dart image 库模板匹配）→ 用预存的"输入框"/"发送按钮"小图在截屏里匹配出真实坐标
3. dispatchGesture → 点击坐标 ✅
不读节点、不碰协议、不逆向，绕过了微信所有 accessibility 防护。

# 任务1：移除 RPA 自动回复（保留智能复制+跳群）

调研已确认 RPA 功能完全自包含。移除步骤：

### 删除整文件/目录
- `lib/infrastructure/rpa/`（rpa_auto_reply.dart、template_store.dart、template_matcher.dart）
- `lib/presentation/pages/rpa_onboarding/`（rpa_onboarding_page.dart、crop_selector.dart）
- `android/.../RpaAccessibilityService.kt`、`HbToBitmap.kt`
- `android/.../res/xml/rpa_accessibility_config.xml`
- 测试：rpa_auto_reply_test.dart、template_matcher_test.dart、template_store_test.dart、crop_selector_test.dart

### 编辑引用点（保留宿主功能）
- **reply_sheet.dart**：`_choosePhrase` 简化为直接调 `_smartCopy`（删除 RPA 分支判断）；删除 `_runAutoChain`/`_showProgress`；删 RPA import
- **providers.dart**：删除 PlatformActions 里所有 rpa 方法（rpaTap/rpaLongPress/rpaScreenshotAndMatch/rpaDetectInputBox/rpaPasteViaAccessibility/rpaSaveDebugScreenshot/rpaRawScreenshot/isRpaServiceEnabled）+ RpaMatchResult/RpaInputBoxPoint/RpaPasteOutcome 类 + templateStoreProvider/inputBoxTemplatePathProvider/rpaTemplatesReadyProvider/rpaAutoReplyEnabledProvider。**保留** appLifecycleProvider（通用）、jumpToChat/launchWechat/copyToClipboard（智能复制用）
- **settings_page.dart**：删除 RPA 实验功能区段 + `_rpaAutoReplyTile`
- **router.dart**：删 rpa_onboarding import + 子路由
- **AndroidManifest.xml**：删 `<service android:name=".RpaAccessibilityService">` 声明
- **NotificationPlugin.kt**：删所有 rpa* 通道方法分支 + rpaScope 字段
- **AppLauncher.kt**：删 `isRpaServiceEnabled`（保留 isAccessibilityEnabled/openAccessibilitySettings 通用方法，只改注释）
- **pubspec.yaml**：移除 `image` 依赖（仅 RPA 用）；flutter pub get

### 注释清理（不改逻辑）
app.dart / MainActivity.kt 里 "RPA" 字样泛化为"后台返回黑屏修复"等通用表述

---

# 任务2：高德地图距离/费用计算

采用 REST API + 地址文本输入 + 网约车估算。严格遵循六边形架构。

### 依赖
- pubspec 新增 `dio: ^5.4.0`（HTTP 客户端）
- AndroidManifest 已有 INTERNET 权限，无需新增

### Domain 层（纯 Dart，不引外部包）
- **`entities/route_estimate.dart`**（freezed）：`RouteEstimate`（起点/终点经纬度+地址、距离米、时长秒、估算费用元、车型）
- **`entities/fare_rule.dart`**（freezed）：`FareRule`（起步价、起步里程、里程费/公里、时长费/分钟、车型），含 `estimate(distanceMeters, durationSeconds)` 方法算费用
- **`repositories/i_route_gateway.dart`**：抽象接口 `Future<Either<Failure, RouteEstimate>> calculateDistance({origin, destination})`，入参用纯 double 经纬度，不引高德类型
- **failure.dart**：新增 `NetworkFailure`

### Infrastructure 层
- **`amap/amap_route_gateway.dart`** implements IRouteGateway：用 dio 调高德 REST：
  - 地理编码 `https://restapi.amap.com/v3/geocode/geo`（地址→经纬度）
  - 距离 `https://restapi.amap.com/v3/distance`（起终点经纬度→距离+时长）
  - try/catch → right/left，错误映射 NetworkFailure/GatewayFailure
  - API Key 从环境/常量读取（先用占位常量 + 注释说明替换）
- **`amap/fare_rules.dart`**：默认网约车费率（经济型/舒适型），可配置

### Presentation 层
- **`pages/route_calc/route_calc_page.dart`**：起点/终点地址输入框 + "计算"按钮 + 结果展示（距离、时长、各车型费用）+ 错误提示
- **`pages/route_calc/fare_config_page.dart`**（可选）：费率配置
- **providers.dart**：注册 `amapRouteGatewayProvider`、`routeEstimateProvider`（FutureProvider.autoDispose，入参起点终点）
- **router.dart**：新增第 5 个 tab"出行"或作为消息 branch 子路由 `/route_calc`

### 验证
- `dart run tool/domain_lint.dart` 确认 domain 层无外部依赖
- flutter analyze + flutter test 全过
- 构建安装验证

## 关于高德 API Key
REST API 需要一个有效的高德 Web 服务 Key。我会用占位常量 `const _amapApiKey = 'YOUR_AMAP_KEY'` 并注释说明去高德开放平台申请替换。用户提供 Key 后填入即可。
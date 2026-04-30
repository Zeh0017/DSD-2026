# S2 模块实现总结报告

## 1. 项目概述

本项目是 DSD 2025-2026 课程项目 "Limb Motion Recognition and Assistant" 的一部分。S2（数据采集与处理）模块负责从 S1（IMU 传感器）读取原始数据、验证处理后，将格式化数据交付给 M1（患者手机 App）和 V2（后端 API）。

项目使用鸿蒙（HarmonyOS）ArkTS/ArkUI 开发，运行在手机端。

---

## 2. 实现过程时间线

### 第一阶段：S2 核心模块实现

**起点状态**：仓库中只有 M1 组的代码，S2 代码尚未编写。M1 所有传感器数据都是模拟生成的（mock），所有 S2 接口调用都是 TODO 占位。

**实现内容**：
1. `entry/src/main/ets/s2/S2DataModels.ets` — 8 个数据模型类（SensorSample、FormatData、SessionContext 等）
2. `entry/src/main/ets/s2/S1SensorAdapter.ets` — S1 传感器模拟适配器（30Hz 正弦运动数据）
3. `entry/src/main/ets/s2/S2V2HttpClient.ets` — V2 HTTP 客户端（3 个端点）
4. `entry/src/main/ets/s2/S2DataAcquisitionService.ets` — S2 核心服务（start/stop/read 接口）
5. 修改 `RehabilitationService.ets` — 集成 S2 管线替代 mock 数据
6. 修改 `module.json5` — 添加 `ohos.permission.INTERNET` 权限

### 第二阶段：M1 前端补全

**实现内容**：
1. `HomePage.ets` — 从占位符实现为完整的患者主页（欢迎区、快速开始、最近训练摘要）
2. `RecordPage.ets` — 从占位符实现为训练历史列表
3. `LocalStorageService.ets` — 基于 `@ohos.data.preferences` 的本地会话持久化
4. `TestPage.ets` — 增加 "Start Training" 直达按钮
5. 修复训练流程阻断：注释掉 M1 层多余的 BLE 预检查，让 S2→S1 链路自行判断
6. 修复 `SessionActivePage.ets` 的 EndConfirmDialog 布局 bug（Column→Stack）

### 第三阶段：S2 严格 SRS 合规修复

逐条对照 `s2-implementation-guide.md` 中的 6 个 SRS 用例，补齐所有缺失的细节：

| SRS 用例 | 补充内容 |
|---------|---------|
| IUC-S2-01-01 | start() 增加 token 参数、参数有效性验证（ValueError） |
| IUC-S2-01-02 | stop() 增加 S1.stopSession() 确认 |
| IUC-S2-02-01 | V2 确认接收监控子进程、错误异步传播（v2PendingErrors → 下次 read() 返回）、HTTP 超时配置 |
| IUC-S2-03-01 | S1Adapter 增加 startSession(metaData) 方法 |
| IUC-S2-03-02 | S1Adapter 增加 stopSession() 方法 |
| IUC-S2-03-03 | S1 read 超时检测（2 秒无数据 → timeout ErrorEvent） |

### 第四阶段：日志系统

1. 创建 `FileLoggerService.ets` — 集中式日志服务
2. 定义 6 个日志级别：DETAIL / DEBUG / INFO / WARN / ERROR / FATAL
3. 所有模块统一使用 `Logger.info('Tag', 'message')` 接口
4. 所有 tag 加 `APP/` 前缀，方便过滤：`hdc hilog | grep APP/`
5. 替换项目中所有 `hilog` 和 `console.log` 调用

---

## 3. 遇到的问题与解决方案

### 3.1 ArkTS 编译兼容性问题

| 问题 | 原因 | 解决 |
|------|------|------|
| `arkts-no-untyped-obj-literals` | ArkTS 不允许匿名对象字面量（`.map(x => ({...}))`） | 为每种 payload 创建显式 class（TargetAnglePayload 等） |
| `RequestMethod.PATCH` 不存在 | HarmonyOS http 模块不支持 PATCH 方法 | 使用 PUT + `X-HTTP-Method-Override: PATCH` header |
| `arkts-limited-throw` | ArkTS 的 throw 只能抛出 Error 类型，不能 re-throw unknown | 将 `throw error` 改为 `throw new Error(\`...\${String(error)}\`)` |
| Logger 参数不匹配 | hilog 用 printf 格式化（`%{public}s`），Logger 只接受 2 参数 | 全部改为模板字符串拼接 |

### 3.2 训练流程阻断

**问题**：在没有物理 BLE 传感器时，训练流程完全走不通。

**根因**：M1 原代码在 `RehabilitationService.startSession()` 和 `SessionSetupPage.checkSensorConnection()` 中直接检查 BLE 连接状态，但按设计，传感器连接检查应由 S2→S1 链路负责。

**解决**：
- 注释掉 M1 层的 BLE 预检查（保留原代码，标注 `[S1-REAL]`）
- `S1SensorAdapter.status()` 在 mock 模式下永远返回 `connected=true`
- `isSensorConnected()` 改为查询 S2→S1 链路而非直接查 BLE

### 3.3 EndConfirmDialog 不显示

**问题**：点击 "End Session" 后只有暗色遮罩，看不到确认弹窗。

**根因**：M1 原代码用 `Column`（垂直布局）包裹遮罩和弹窗内容，遮罩 `height('100%')` 独占了全部空间，弹窗被挤到视口外。

**解决**：将外层 `Column` 改为 `Stack`（叠加布局），遮罩和弹窗重叠显示。

### 3.4 日志文件写入中断

**问题**：应用启动阶段的日志正常写入文件，但会话开始后（30Hz 高频写入）日志文件不再更新，而 HiLog 面板中日志完整。

**根因**：`fileIo.writeSync` 在 30Hz 高频写入下（每秒约 30+ 条来自 S1Adapter.status()）导致文件 I/O 过载，文件描述符异常。

**解决**：放弃文件日志方案，全部走 HiLog。通过 `hdc hilog | grep APP/` 在电脑端实时捕获并保存日志。

### 3.5 V2 接口格式不匹配

**现状**（已确认，待修复）：

| 端点 | 我们发送的 | V2 期望的 | V2 响应 |
|------|-----------|----------|---------|
| `POST /sessions` | `{"userId": 1}` | 需要已注册的 userId | 404 `User not found` |
| `POST /measurements/batch` | `{"sessionID": ..., "targetAngles": [...]}` | `{"sessionId": ..., "measurements": [...]}` | 400 `sessionId and measurements array are required` |
| `PUT /sessions/:id/end` | fallback ID | 不存在的 session | 404 |

**根因**：
- 协商文档中的字段名（`sessionID` 大写 D）与 V2 实际实现（`sessionId` 小写 d）不一致
- V2 期望 `measurements` 数组，我们发送的是 `targetAngles`
- userId=1 在 V2 数据库中不存在（未注册用户）

---

## 4. 关键设计决策

### 4.1 代码组织

- S2 代码全部放在独立目录 `entry/src/main/ets/s2/` 下，与 M1 的 `service/` 分离
- 所有注释掉的代码保留（不直接删除），标注 `[S1-REAL]` 或 `[V2-TODO]`

### 4.2 V2 缺失的变通方案

所有因 V2 不可用的变通方案用 `[V2-TODO]` 标记，集中隔离：

| 位置 | 变通方案 | V2 就绪后替换为 |
|------|---------|---------------|
| RehabilitationService | userId 硬编码 1 | V2 登录返回的 userId |
| RehabilitationService | token 为空字符串 | V2 认证 token |
| RehabilitationService | V2 创建 session 失败用时间戳 fallback | V2 正常创建 |
| SessionSetupPage | 硬编码 4 个运动计划 | V2 `GET /exercises` |
| LocalStorageService | 本地 Preferences 存储 | V2 API |
| ProfilePage | 本地模拟登录 | V2 `POST /auth/login` |
| RegisterPage | 本地模拟注册 | V2 `POST /auth/register` |

### 4.3 FormatData → RealtimeRecognitionResult 转换

转换层放在 M1 侧的 `RehabilitationService.convertFormatDataToResult()` 中，将 S2 的动态 angleID 映射为 M1 UI 的固定 knee/hip/ankle 模型。这样 S2 不依赖 M1 的 UI 结构。

### 4.4 日志系统设计

- 6 个日志级别：DETAIL / DEBUG / INFO / WARN / ERROR / FATAL
- 全部输出到 HiLog，tag 统一加 `APP/` 前缀
- 电脑端通过 `hdc hilog | grep APP/` 捕获
- DETAIL 级别用于 30Hz 高频调用（仅 HiLog），DEBUG 及以上用于关键事件

---

## 5. 当前项目状态

### 5.1 正常工作的功能

- 完整的训练流程：登录 → 选择运动 → 开始会话 → 实时数据展示 → 结束 → 结果展示
- S1 mock 30Hz 数据生成（正弦运动模拟）
- S2 数据采集、验证、缓冲、交付
- M1 实时 UI 更新（关节角度、评分、告警）
- 本地会话历史持久化
- V2 HTTP 通信（服务器可达，但格式需联调）
- 日志系统完整覆盖

### 5.2 已知问题

1. **V2 上传格式不匹配**：字段名大小写（sessionID vs sessionId）和数据结构（targetAngles vs measurements）需要与 V2 组联调确认
2. **V2 用户不存在**：需要在 V2 上注册用户或协商 userId 的获取方式
3. **关节角度 UI 显示 0°**：sensorJointMapping 为 undefined 时，默认只输出 knee 角度，hip/ankle 没有数据源

### 5.3 文件清单

| 文件 | 行数 | 状态 |
|------|------|------|
| `s2/S2DataModels.ets` | 100 | 新建 |
| `s2/S1SensorAdapter.ets` | 174 | 新建 |
| `s2/S2V2HttpClient.ets` | 280 | 新建 |
| `s2/S2DataAcquisitionService.ets` | 593 | 新建 |
| `service/RehabilitationService.ets` | 589 | 大幅修改 |
| `service/FileLoggerService.ets` | 120 | 新建 |
| `service/LocalStorageService.ets` | 98 | 新建 |
| `pages/HomePage.ets` | 191 | 重写 |
| `pages/RecordPage.ets` | 191 | 重写 |
| `pages/TestPage.ets` | 114 | 修改 |
| `pages/rehabilitation/SessionSetupPage.ets` | 356 | 修改 |
| `pages/rehabilitation/SessionActivePage.ets` | 581 | 修改（EndConfirmDialog 修复） |
| `entryability/EntryAbility.ets` | 45 | 修改 |
| `module.json5` | 43 | 修改（添加 INTERNET 权限） |

**总计**：14 个文件，约 3,675 行代码。

---

## 6. 后续工作

1. **V2 联调**：修正上传格式（字段名、数据结构），注册测试用户
2. **S1 集成**：当 S1 固件就绪后，替换 S1SensorAdapter 的 mock 实现
3. **V2 认证集成**：实现真实登录/注册流程，获取 token 和 userId
4. **关节角度 UI**：修复 hip/ankle 显示为 0° 的问题

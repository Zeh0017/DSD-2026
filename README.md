# 我的鸿蒙应用

## 项目简介

一个简单的底部四页签应用示例，包含主页、测试、记录、个人四个页面。集成了 S2 数据采集模块，支持传感器数据采集、处理、实时展示和后端上传。

## 页面说明

- **主页**：患者仪表板，显示欢迎信息、快速开始训练入口、最近训练摘要
- **测试**：康复训练入口，支持直接开始训练或连接 BLE 传感器
- **记录**：训练历史列表，显示所有已完成会话的评分、时长等
- **个人**：提供登录功能，支持用户名密码登录

## 使用说明

1. 使用 DevEco Studio 6.0.2+ 打开项目
2. 同步项目依赖
3. 运行到设备或模拟器

## 项目结构

```
MyHarmonyApp/
├── AppScope/                    # 应用全局配置
│   ├── app.json5                # 应用配置
│   └── resources/               # 应用资源
├── entry/                       # 入口模块
│   ├── src/main/
│   │   ├── ets/                 # ArkTS 源码
│   │   │   ├── pages/           # 页面
│   │   │   │   ├── Index.ets    # 主页面（底部页签）
│   │   │   │   ├── HomePage.ets # 主页
│   │   │   │   ├── TestPage.ets # 测试页
│   │   │   │   ├── RecordPage.ets # 记录页
│   │   │   │   ├── ProfilePage.ets # 个人页（含登录）
│   │   │   │   ├── RegisterPage.ets # 注册页
│   │   │   │   └── rehabilitation/  # 康复训练子页面
│   │   │   │       ├── SensorConnectionPage.ets # BLE 传感器连接
│   │   │   │       ├── SessionSetupPage.ets     # 运动选择、启动会话
│   │   │   │       ├── SessionActivePage.ets    # 训练中：实时反馈
│   │   │   │       └── SessionResultPage.ets    # 训练结果
│   │   │   ├── s2/              # S2 数据采集模块（新增）
│   │   │   │   ├── S2DataModels.ets             # S2 数据模型定义
│   │   │   │   ├── S1SensorAdapter.ets          # S1 传感器适配器（当前为模拟）
│   │   │   │   ├── S2V2HttpClient.ets           # V2 后端 HTTP 客户端
│   │   │   │   └── S2DataAcquisitionService.ets # S2 核心数据采集服务
│   │   │   ├── service/         # 服务层
│   │   │   │   ├── BleManager.ets               # BLE 管理器
│   │   │   │   ├── RehabilitationService.ets    # 康复训练服务（集成 S2）
│   │   │   │   ├── LocalStorageService.ets      # 本地会话持久化（新增）
│   │   │   │   └── FileLoggerService.ets        # 日志服务（新增）
│   │   │   ├── model/           # 数据模型
│   │   │   │   └── TabModel.ets # 页签配置
│   │   │   ├── designtoken/     # 设计令牌
│   │   │   └── entryability/    # 应用入口
│   │   └── resources/           # 资源文件
│   └── build-profile.json5      # 模块构建配置
├── docs/                        # 文档
│   └── 26-04-30-00 ZhiqiZHANG modify.md  # 2026.04.30 修改详情
├── IMPLEMENTATION_SUMMARY.md    # 实现总结
├── build-profile.json5          # 应用构建配置
└── oh-package.json5             # 包配置
```

## 更新日志

### 2026.04.30 - S2 Data Acquisition Module (Zhiqi ZHANG)

S2 组 Zhiqi ZHANG 完成了 S2 数据采集模块的实现及 M1 前端的补全：

- 新增 `entry/src/main/ets/s2/` 目录：S2 核心模块（数据模型、S1 适配器、V2 HTTP 客户端、数据采集服务）
- 新增 `LocalStorageService.ets`：本地会话历史持久化
- 新增 `FileLoggerService.ets`：统一日志系统（HiLog 输出，`APP/` 前缀）
- 实现 `HomePage.ets`、`RecordPage.ets`：从占位符实现为完整页面
- 修改 `RehabilitationService.ets`：集成 S2 数据管线，替代原有 mock 数据
- 修改 `SessionActivePage.ets`：修复 EndConfirmDialog 布局 bug
- 修改 `module.json5`：添加 INTERNET 网络权限
- S2 实现严格按照 SRS 6 个用例（IUC-S2-01-01 ~ IUC-S2-03-03）

更多关于本次修改的细节请见 `docs/26-04-30-00 ZhiqiZHANG modify.md`

## 开发环境

- HarmonyOS SDK: 6.0.2+
- DevEco Studio: 6.0.2+

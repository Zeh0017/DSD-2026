# 我的鸿蒙应用

## 项目简介

一个简单的底部四页签应用示例，包含主页、测试、记录、个人四个页面。

## 页面说明

- **主页**：空白页面，后续可添加内容
- **测试**：空白页面，后续可添加内容
- **记录**：空白页面，后续可添加内容
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
│   │   │   │   └── ProfilePage.ets # 个人页（含登录）
│   │   │   ├── model/           # 数据模型
│   │   │   │   └── TabModel.ets # 页签配置
│   │   │   ├── designtoken/     # 设计令牌
│   │   │   └── entryability/    # 应用入口
│   │   └── resources/           # 资源文件
│   └── build-profile.json5      # 模块构建配置
├── build-profile.json5          # 应用构建配置
└── oh-package.json5             # 包配置
```

## 开发环境

- HarmonyOS SDK: 6.0.2+
- DevEco Studio: 6.0.2+

# 技术栈决策

## 已确定 MVP 技术栈

### 桌面端

| 技术 | 版本 | 用途 | 决策理由 |
|------|------|------|---------|
| Wails | v3 | 跨平台桌面框架 | Go 本地桥接 + Web 前端，适合 Windows/macOS 轻量桌面工具 |
| Vue | 3.x | UI 框架 | 生态成熟，组合式 API 适合复杂工具界面 |
| TypeScript | 5.x | 类型安全 | AI 请求/本地配置/生成记录需要明确类型 |
| Element Plus | 2.x | UI 组件库 | Vue 3 生态成熟，适合设置表单、上传、表格、弹窗 |
| Fabric.js | 6.x | Canvas 编辑/预览 | 商品图预览、裁剪、文字、Logo、图层编辑和详情长图排版预览 |
| Pinia | 2.x/3.x | 状态管理 | 管理 AI 配置、生成任务、项目历史 |
| Vue Router | 4.x | 页面路由 | 设置页、生图页、历史页、导出页 |
| Vitest | — | 前端测试 | 组件和工具函数测试 |

### 本地数据与文件

| 技术 | 用途 | 决策理由 |
|------|------|---------|
| JSON 配置文件 | AI Provider 设置、本地偏好 | MVP 简单直接，便于调试 |
| 本地文件系统 | 上传图副本、输出图、导出文件 | 桌面工具核心能力，路径由 Go Bridge 跨平台管理 |
| SQLite（后续） | 项目、素材、历史记录结构化存储 | 当 JSON 难以维护时再引入 |
| 系统凭证/本地加密（后续） | API Key 加密保存 | Windows Credential Manager / macOS Keychain 用于正式版安全增强 |

### AI Provider

| 技术/模式 | 用途 | 决策理由 |
|----------|------|---------|
| OpenAI-compatible API | 默认接口兼容层 | 多数中转站兼容 OpenAI 风格请求，由 Go Bridge Provider Adapter 调用 |
| Custom Gateway Adapter | 自定义中转站适配 | 允许用户使用不同模型中转站，字段映射集中在 Go 层 |
| 用户手动配置 Base URL / API Key / Model | BYOK 模式 | 不需要云端管理，快速验证桌面产品 |
| Go HTTP Client | 外部 API 请求 | 统一处理代理、超时、TLS、图片下载和 base64 解码，避免前端 WebView 直连 |

## 不纳入当前技术栈的内容

为了减少开发干扰，当前仓库不维护以下方向：

| 内容 | 原因 |
|------|------|
| 服务端业务系统 | 当前产品是桌面工具，核心闭环在本地完成 |
| 管理后台 | 当前不做运营管理能力 |
| 服务端数据库 | 配置、历史、输出优先本地保存 |
| 任务队列 | 先做单商品主图/详情分段生成和本地重试 |
| 订阅/积分/支付 | 用户自带模型服务账号和访问凭证 |

## 桌面端可以直接使用的能力

- ✅ 用户自填 AI API Base URL
- ✅ 用户自填 API Key
- ✅ 用户自填模型名
- ✅ 本地保存配置与生成历史
- ✅ 上传商品参考图
- ✅ 调用用户配置的 AI 中转站（经 Go Bridge Provider Adapter）
- ✅ 本地结果保存和导出
- ✅ Windows/macOS AppData 路径统一管理
- ✅ Fabric.js/Canvas 详情长图预览和轻量编辑
- ✅ Go Image Composer 超长图导出兜底（预留/后续增强）

## 可选增强技术

| 方向 | 候选 | 用途 |
|------|------|------|
| 本地存储增强 | SQLite | 大量历史记录、项目/SKU 管理 |
| Key 安全 | Windows Credential Manager / macOS Keychain / 本地加密 | API Key 安全保存 |
| 本地图像处理 | Go image / imaging / libvips（后续评估） | 超长详情图稳定拼接、缩放、压缩、批处理和导出兜底 |
| 桌面打包 | Wails build | Windows x64、macOS arm64/amd64/Universal 发布 |

## 设计原则

1. 先完成桌面端电商图片生成业务闭环。
2. AI Provider 差异通过 Go Bridge Provider Adapter 处理，不写死单一模型。
3. 外部 AI API 请求不由前端 WebView 直连，统一交给 Go 层处理网络、代理、超时和文件保存。
4. Prompt 和平台规则是核心资产，应在本地结构化维护。
5. 商品主体保持优先于画面风格变化。
6. 广告文字优先通过 Fabric.js 后期叠加，不强依赖模型直接生成文字。
7. Fabric.js 负责预览和轻量编辑，超长详情图导出预留 Go Image Composer 兜底。
8. 不引入与桌面 MVP 无关的服务端复杂度。

# 技术栈决策

## 已确定技术栈

### 桌面端

| 技术 | 版本 | 用途 | 决策理由 |
|------|------|------|---------|
| Wails | v3 | 桌面框架 | Go 后端 + Web 前端的桌面方案，与云端共享 Go 生态 |
| Vue | 3.x | UI 框架 | 生态成熟，Pinia/Element Plus 配套完善 |
| TypeScript | 5.x | 类型安全 | 团队偏好，减少运行时错误 |
| Element Plus | 2.x | UI 组件库 | Vue 3 生态最成熟的企业级组件库 |
| Fabric.js | 6.x | Canvas 编辑 | 图片标注/预览/轻量编辑 |
| Pinia | 2.x | 状态管理 | Vue 3 官方推荐 |
| SQLite | — | 本地缓存 | Wails 内置支持，无需额外安装 |

### 云端服务

| 技术 | 版本 | 用途 | 决策理由 |
|------|------|------|---------|
| Go | 1.22+ | 后端语言 | 性能好，并发原生支持，与 Wails 一致 |
| Gin | 1.x | HTTP 框架 | 高性能，中间件生态丰富 |
| GORM | 2.x | ORM | Go 生态最成熟的 ORM，支持迁移/事务/预加载 |
| MySQL | 8.0 | 业务数据库 | 成熟稳定，支持 JSON/CTE/窗口函数 |
| Redis | 7.x | 缓存/队列 | Asynq 依赖，高性能 KV |
| Asynq | 0.24+ | 任务队列 | Go 原生，支持重试/延迟/优先级/中间件 |

### AI 与存储

| 技术 | 用途 | 决策理由 |
|------|------|---------|
| GPT-Image-2 | 主生图引擎 | 产品方案确定 |
| 背景移除服务 | 预处理 | 确定性服务，成本低（候选：remove.bg API 或自建） |
| 对象存储 | 图片存储 | 候选：阿里云 OSS / 腾讯云 COS / Cloudflare R2 / AWS S3 |
| CDN | 图片分发 | 与对象存储配套 |

## 桌面端不引入的技术

- ❌ 不在桌面端嵌入 OpenAI SDK 或 API Key
- ❌ 不在桌面端直连 MySQL
- ❌ 不在桌面端运行 Redis
- ❌ 不在桌面端做 AI 推理

## 备选/待定

| 领域 | 候选 | 备注 |
|------|------|------|
| 日志 | zerolog / zap | Go 结构化日志 |
| 配置 | viper | Go 配置管理 |
| API 文档 | swaggo/swag | 自动生成 OpenAPI spec |
| 测试 | testify + httptest | Go 测试框架 |
| 前端测试 | Vitest + Playwright | Vue 组件测试 |
| 图片处理 | bimg / imaging | Go 图片处理库 |
| 支付 | 支付宝 / 微信支付 / Stripe | 待定 |

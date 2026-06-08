# 电商 AI 生图桌面工具 — 项目文档中心

## 项目概述

面向电商卖家/运营的桌面端 AI 商品图生成工具，支持多平台（Amazon、Shopify、TikTok、抖音、小红书）商品图批量生成与合规导出。

## 文档分层

```text
docs/
├── product/        ← 产品需求、功能规格、用户故事
├── architecture/   ← 系统架构、技术方案、模块设计
├── development/    ← 开发指南、环境搭建、编码规范、Agent 自动化
├── decisions/      ← 架构决策记录 (ADR)
skills/             ← 项目内 Agent 技能规范文档
workflows/          ← 多 Agent 流程规范文档
.claude/            ← Claude Code 配置 (settings, MCP)
server/             ← 服务端代码 (migrations 等)
```

## 技术栈

| 层 | 技术 |
|---|------|
| 桌面端 | Wails + Vue 3 + TypeScript + Element Plus + Fabric.js |
| 云端 API | Go + Gin + GORM |
| 数据库 | MySQL 8.0 (业务主库) + SQLite (桌面缓存) |
| 队列/缓存 | Redis + Asynq |
| AI 引擎 | OpenAI GPT-Image-2 |
| 存储 | 对象存储 (OSS/COS/R2/S3) + CDN |

## 快速链接

- [产品方案](docs/product/PRD.md)
- [系统架构](docs/architecture/system-design.md)
- [技术栈决策](docs/architecture/tech-stack.md)
- [数据库设计](docs/architecture/database-schema.md)
- [开发环境搭建](docs/development/environment-setup.md)
- [Agent 自动化开发指南](docs/development/agent-automation.md)
- [Claude 自动审查配置](docs/development/review-automation.md)
- [自动化书写功能实现文档](docs/development/feature-implementation-docs.md)
- [自动 CI 审查配置](docs/development/ci-review.md)
- [架构决策记录](docs/decisions/)
- [数据库操作规则](DATABASE_RULES.md)

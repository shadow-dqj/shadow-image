# 电商 AI 生图桌面工具 — 项目文档中心

## 项目概述

面向电商卖家/运营人员的**桌面端 AI 商品图生成工具**。MVP 阶段聚焦桌面端业务闭环：用户在本地手动填写 AI 中转站/模型 API 地址、Key 和模型名，上传商品参考图，输入/选择电商场景 Prompt，生成符合 Amazon、Shopify、TikTok、抖音、小红书等平台需求的商品图，并在本地预览、保存和导出。

> 当前优先级：打磨桌面端 AI Agent 作图流程，持续围绕电商图片生成业务优化。

## MVP 范围

```text
桌面端本地工具
├── AI 配置：Base URL / API Key / Model / 接口类型 / 超时
├── 商品图上传：拖拽、本地预览、格式校验
├── 电商场景：平台、图片类型、尺寸、风格、Prompt 模板
├── 提示词优化：根据商品信息、平台规则、图片目标优化 Prompt / Negative Prompt
├── AI 生图：调用用户配置的 OpenAI-compatible / 中转站接口
├── 结果管理：预览、历史、本地保存、重新生成
└── 导出：按平台尺寸/格式导出图片
```

## 文档分层

```text
docs/
├── product/        ← 产品需求、MVP 功能规格、用户故事
├── architecture/   ← 桌面端架构、AI Provider、本地存储、提示词优化
├── development/    ← 开发指南、编码规范、Agent 自动化
├── decisions/      ← 架构决策记录 (ADR)
skills/             ← 项目内 Agent 技能规范文档
workflows/          ← 多 Agent 流程规范文档
.claude/            ← Claude Code 配置 (settings, MCP)
desktop/frontend/   ← Vue 3 + Element Plus + Fabric.js 桌面 UI
```

## 技术栈

| 层 | 技术 | MVP 用途 |
|---|------|---------|
| 桌面壳 | Wails + Go Bridge | 本地文件、配置、保存、后续系统能力 |
| 前端 UI | Vue 3 + TypeScript + Element Plus | 设置页、生图页、提示词优化页、结果页、历史页 |
| 图像编辑 | Fabric.js | 商品图预览、轻量编辑、文字/图层叠加 |
| 状态管理 | Pinia | AI 配置、项目、生成历史、UI 状态 |
| 本地存储 | JSON/SQLite（逐步演进） | 配置、项目、素材、生成历史 |
| AI 接口 | OpenAI-compatible / 自定义中转站 API | 用户手动填写 Base URL、API Key、Model |
| 导出 | 浏览器/Wails 文件能力 | 本地保存、平台规格导出 |

## 快速链接

- [产品方案](docs/product/PRD.md)
- [AI Agent 作图流程](docs/product/agent-image-workflow.md)
- [系统架构](docs/architecture/system-design.md)
- [技术栈决策](docs/architecture/tech-stack.md)
- [开发环境搭建](docs/development/environment-setup.md)
- [Agent 自动化开发指南](docs/development/agent-automation.md)
- [Claude 自动审查配置](docs/development/review-automation.md)
- [自动化书写功能实现文档](docs/development/feature-implementation-docs.md)
- [自动 CI 审查配置](docs/development/ci-review.md)
- [架构决策记录](docs/decisions/)

## 下一步开发重点

1. 完成桌面端路由、Pinia、页面骨架。
2. 实现 AI Provider 设置页：Base URL、API Key、Model、接口类型、测试连接。
3. 实现商品图上传与本地预览。
4. 实现电商 Prompt/平台规则选择：Amazon 白底图、Shopify 场景图、TikTok 竖版广告、小红书封面。
5. 集成提示词优化功能：基于商品信息、平台规则、图片目标生成优化后的 Prompt 和 Negative Prompt。
6. 调用用户配置的中转站 API 完成单张图片生成。
7. 展示结果并保存到本地历史。
8. 增加平台规格导出和轻量编辑能力。

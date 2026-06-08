# Claude Agent 自动化开发指南

## 概述

本项目用 `skills/` 与 `workflows/` 目录沉淀 Agent 开发规范。注意：这些 Markdown 文件是项目约定文档，不会自动注册为 Claude Code slash skill 或可执行 workflow；执行前必须显式读取并按规范操作。

## Agent 开发分层

```text
skills/          ← 单 Agent 技能规范文档（原子能力）
workflows/       ← 多 Agent 流程规范文档（流程能力）
docs/            ← 知识和上下文（Agent 从文档获取项目知识）
.claude/         ← 配置（工具权限、MCP 连接）
```

## Skills vs Workflows

| 维度 | Skills | Workflows |
|------|--------|-----------|
| 粒度 | 原子操作 | 多步骤流程 |
| Agent 数 | 单个 | 多个 (fan-out) |
| 适用 | 代码生成、检查、修复 | 全流程开发、审查、迁移 |
| 示例 | `generate-go-model` | `full-feature-dev` |

## 标准开发工作流

### 新功能开发流程

```text
1. 需求确认   →  阅读 docs/product/PRD.md
2. 设计确认   →  阅读 docs/architecture/
3. 数据库变更  →  Agent 创建 migration
4. 模型生成   →  Agent 生成 Go model
5. API 生成   →  Agent 生成 handler/service/repository
6. 前端生成   →  Agent 生成 Vue 组件
7. 测试生成   →  Agent 生成测试
8. 代码审查   →  Agent 审查代码
```

### 触发方式

```bash
# 功能开发
@claude 实现用户认证模块

# 数据库变更
@claude 创建 credit_transactions 表

# 代码审查
@claude review 最近修改的代码
```

## Agent 可用的上下文

只有 `CLAUDE.md` 保证会被 Claude Code 自动加载。其他文档必须在执行对应任务前显式读取：

1. `CLAUDE.md` — 项目概述和架构决策（每次自动加载）
2. `docs/product/PRD.md` — 产品需求（做产品/功能设计前读取）
3. `docs/architecture/` — 架构和技术文档（做模块/接口/存储设计前读取）
4. `docs/development/coding-standards.md` — 编码规范（写代码前读取）
5. `DATABASE_RULES.md` — 数据库操作规则（生成或执行迁移前必须读取）
6. `server/migrations/` — 现有迁移（生成模型或新迁移前必须读取）

## Skill 开发规范

每个 Skill 文件应包含：

```markdown
# skill-name

## 描述
简短描述该 skill 的功能

## 触发条件
什么情况下触发这个 skill

## 上下文依赖
需要阅读哪些文档

## 输入
- param1: 描述
- param2: 描述

## 输出
- 生成的文件/代码

## 示例
使用示例
```

## 工作流开发规范

每个 Workflow 文件应包含：

```markdown
# workflow-name

## 描述
多步骤流程描述

## 阶段
1. Phase 1 — 描述
2. Phase 2 — 描述
3. Phase 3 — 描述

## Agent 编排
- Finder: N 个并行 Agent 各自搜索
- Verifier: 每个发现用 M 个 Agent 验证
- Synthesizer: 1 个 Agent 合成结果

## 输入
## 输出
```

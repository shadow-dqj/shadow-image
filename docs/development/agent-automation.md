# Claude Agent 自动化开发指南

## 概述

本项目当前优先开发**桌面端电商 AI 商品图生成 MVP**。`skills/` 与 `workflows/` 目录用于沉淀 Agent 开发规范，但执行前必须结合当前方向：先做桌面工具和 AI Provider 配置，不优先做云端/数据库/管理后台。

## Agent 开发分层

```text
skills/          ← 单 Agent 技能规范文档（原子能力）
workflows/       ← 多 Agent 流程规范文档（流程能力）
docs/            ← 知识和上下文（Agent 从文档获取项目知识）
.claude/         ← 配置（工具权限、MCP 连接）
```

## 当前标准开发工作流

### 桌面端 MVP 新功能流程

```text
1. 需求确认      → 阅读 docs/product/PRD.md
2. 架构确认      → 阅读 docs/architecture/system-design.md
3. 类型设计      → 定义 TypeScript 类型和 Provider 接口
4. Store 设计    → Pinia 管理设置/项目/生成历史
5. 页面实现      → Vue + Element Plus 组件
6. AI 适配       → OpenAI-compatible / Custom Gateway Adapter
7. 本地保存      → 配置、上传图、输出图、历史记录
8. 测试与审查    → Vitest/type-check/lint/code-review
```

### 优先功能顺序

```text
1. AI Provider 设置页
2. 商品图上传与预览
3. 平台/图片类型预设
4. Prompt 编辑器
5. 单张 AI 生图调用
6. 结果预览与本地保存
7. 历史记录
8. 导出与 Fabric.js 轻量编辑
```

## Agent 可用的上下文

只有 `CLAUDE.md` 保证会被 Claude Code 自动加载。其他文档必须在执行对应任务前显式读取：

1. `CLAUDE.md` — 当前项目方向和约束
2. `docs/product/PRD.md` — MVP 产品需求
3. `docs/architecture/system-design.md` — 桌面端与 AI Provider 架构
4. `docs/architecture/tech-stack.md` — 技术栈决策
5. `docs/development/coding-standards.md` — Vue/TypeScript/Wails 编码规范
6. `skills/` 和 `workflows/` — 桌面端开发技能/流程规范

## 触发示例

```bash
# MVP 桌面功能
@claude 实现 AI Provider 设置页
@claude 实现商品图上传和预览组件
@claude 实现 OpenAI-compatible 图片生成 Provider
@claude 实现 Amazon 主图 Prompt 预设
@claude 实现生成历史本地保存

# 审查
@claude review 最近修改的桌面端代码
```

## 当前不优先的任务

除非用户明确要求，不要主动优先实现：

- 服务端管理后台
- 服务端数据库 CRUD
- 用户/团队/积分/订阅
- 服务端任务队列
- 服务端对象存储/CDN

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

## MVP 开发注意事项

- 不要在日志、错误、测试快照中输出完整 API Key。
- 不要将用户图片或 Prompt 默认上传到项目自有云端。
- AI Provider 差异必须封装在 adapter/provider 层。
- Prompt 模板和平台规则应集中维护，避免散落在页面中。
- 先跑通单张生成，再做批量 SKU。

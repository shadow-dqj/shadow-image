# full-feature-dev

## 描述

从需求确认到实现的完整功能开发工作流，使用多 Agent 编排。

## 阶段

1. **Understand** — 并行阅读相关文档和现有代码
2. **Design** — 设计变更方案
3. **Implement** — 生成数据库/后端/前端代码
4. **Verify** — 编译检查和代码审查

## Agent 编排

### Phase 1: Understand
- Agent 1: 阅读 PRD 需求描述
- Agent 2: 阅读架构文档
- Agent 3: 阅读相关现有代码

### Phase 2: Design
- Agent: 综合 Phase 1 结果，输出变更设计

### Phase 3: Implement (scope-gated pipeline)
- Step 0: 检查当前脚手架和用户请求范围；未 scaffold 的层只生成计划，不直接写代码
- Step 1: 数据库 migration（仅当需求涉及数据库）
- Step 2: Go model + handler/service/repository（仅当服务端 scaffold 存在或本次任务明确要求先 scaffold）
- Step 3: API 路由注册（仅当路由入口存在）
- Step 4: Vue 页面/组件（仅当前端 scaffold 存在或本次任务明确要求先 scaffold）
- Step 5: 测试（仅当对应测试框架/脚本存在；否则生成测试计划）

### Phase 4: Verify
- Agent 1: 编译检查
- Agent 2: 代码审查
- Agent 3: 安全检查

## 使用方式

```text
@claude 实现 <功能名称>，使用 full-feature-dev 工作流
```

## 前置条件

- 功能描述已在 PRD 或相关文档中定义
- MySQL MCP 可用（如涉及数据库变更）

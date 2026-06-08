# full-feature-dev

## 描述

从需求确认到实现的完整功能开发工作流，使用多 Agent 编排。当前 MVP 主要用于桌面端电商 AI 商品图生成功能。

## 阶段

1. **Understand** — 并行阅读相关文档和现有代码
2. **Design** — 设计桌面端功能方案
3. **Implement** — 生成 TypeScript 类型、Store、Provider、Vue 组件和测试
4. **Verify** — type-check/lint/test/build 和代码审查

## Agent 编排

### Phase 1: Understand
- Agent 1: 阅读 PRD 需求描述，确认电商图片生成业务目标
- Agent 2: 阅读架构文档，确认 AI Provider、本地保存、平台规则边界
- Agent 3: 阅读相关 Vue/TypeScript 现有代码

### Phase 2: Design
- Agent: 综合 Phase 1 结果，输出变更设计
- 明确：页面、组件、store、types、provider adapter、prompt optimizer、本地保存、测试

### Phase 3: Implement (MVP desktop pipeline)
- Step 0: 检查当前前端脚手架和用户请求范围
- Step 1: TypeScript 类型和平台/Prompt 常量
- Step 2: Prompt Optimizer 规则和工具函数（如涉及）
- Step 3: Pinia store 或 composable
- Step 4: AI Provider adapter（如涉及生成/连接测试）
- Step 5: Vue 页面/组件
- Step 6: 本地保存/读取逻辑
- Step 7: Vitest/组件测试

除非用户明确要求，不做服务端接口或管理后台。

### Phase 4: Verify
- Agent 1: type-check/lint/test/build
- Agent 2: 代码审查
- Agent 3: 安全检查（访问凭证脱敏、外部 API 调用提示）

## 使用方式

```text
@claude 实现 AI Provider 设置页，使用 full-feature-dev 工作流
@claude 实现商品图上传与预览，使用 full-feature-dev 工作流
@claude 实现单张 AI 生图调用，使用 full-feature-dev 工作流
```

## 前置条件

- 功能描述已在 PRD 或相关文档中定义
- `desktop/frontend/package.json` 存在
- 如涉及访问凭证保存，必须确认不提交真实凭证、不在日志泄露

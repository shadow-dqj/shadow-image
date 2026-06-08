# scaffold-new-module（桌面端 MVP 版）

## 描述

为桌面端新功能模块生成代码脚手架：types / store / composable / components / views / tests。

## 阶段

1. **Analyze** — 分析模块需求和现有 Vue/TypeScript 代码模式
2. **Contract** — 先定义类型、状态、事件、Provider 边界
3. **Generate** — 生成 store/composable/components/views/tests
4. **Register** — 注册路由或页面入口（如需要）

## Agent 编排

### Phase 1: Analyze
- Agent: 阅读 PRD、架构文档、现有 `desktop/frontend/src` 代码

### Phase 2: Contract
- Agent: 先生成模块契约
  - TypeScript 类型
  - Store state/actions
  - Component props/emits
  - Provider/composable 方法
  - 错误状态

### Phase 3: Generate
- Agent 1: 生成 types/constants
- Agent 2: 生成 Pinia store 或 composable
- Agent 3: 生成业务组件
- Agent 4: 生成页面组件
- Agent 5: 生成 Vitest 测试

> 不要在缺少共享契约时并行生成各层，否则容易出现方法名、类型和 props 不一致。

### Phase 4: Register
- Agent: 注册路由、导航入口或页面引用

## 使用方式

```text
@claude 为 AI Provider 设置创建桌面端模块
@claude 为 generation 创建生图页面和 store
@claude 为 history 创建生成历史模块
```

## 输出示例

```text
desktop/frontend/src/types/<module>.ts
desktop/frontend/src/stores/<module>.ts
desktop/frontend/src/composables/use<Module>.ts
desktop/frontend/src/components/business/<ModulePanel>.vue
desktop/frontend/src/views/<Module>View.vue
desktop/frontend/src/__tests__/<module>.spec.ts
```

## 后续云端说明

服务端 handler/service/repository 脚手架不属于当前桌面 MVP 范围，仅在用户明确要求服务端接口时生成。

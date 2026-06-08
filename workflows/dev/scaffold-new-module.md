# scaffold-new-module（桌面端主图 + 详情长图版）

## 描述

为桌面端新功能模块生成代码脚手架：types / store / bridge service / composable / components / views / tests / Go Bridge contract。适用于 Settings、ProductInput、PromptBuilder、MainImageTask、DetailSectionTask、Composer、Export 等模块。

## 阶段

1. **Analyze** — 分析模块需求、最新架构文档和现有 Vue/TypeScript/Wails 代码模式。
2. **Contract** — 先定义类型、状态、事件、Bridge 边界和错误模型。
3. **Generate** — 生成 store/composable/bridge client/components/views/tests。
4. **Register** — 注册路由、导航入口、store 或 Wails bridge 引用。

## Agent 编排

### Phase 1: Analyze

- Agent: 阅读 PRD、Agent 工作流、桌面工程方案和现有 `desktop/frontend/src` / Wails 代码。
- 确认模块属于哪个阶段：MVP-A / MVP-B / MVP-C。
- 确认是否涉及 Go Bridge、Provider Adapter、本地文件、跨平台路径或导出。

### Phase 2: Contract

先生成模块契约，不要直接写 UI。

契约必须包括：

- TypeScript 类型。
- Store state/actions/getters。
- Component props/emits。
- Bridge client 方法。
- 如涉及 Go Bridge：Go 方法签名或 Wails binding contract。
- 错误状态和用户可读错误信息。
- 本地文件路径/预览 URL 的来源。
- 测试用例清单。

### Phase 3: Generate

- Agent 1: 生成 types/constants。
- Agent 2: 生成 Pinia store 或 composable。
- Agent 3: 生成 bridge client，不直接生成前端 fetch AI Gateway。
- Agent 4: 生成业务组件。
- Agent 5: 生成页面组件。
- Agent 6: 生成 Vitest 测试或 Go 单元测试（如涉及）。

> 不要在缺少共享契约时并行生成各层，否则容易出现方法名、类型、props 和 bridge 方法不一致。

### Phase 4: Register

- 注册路由、导航入口或页面引用。
- 注册 store。
- 如涉及 Wails/Go，确认前端 bridge client 与 Go contract 名称一致。
- 确认不引入服务端 handler/service/repository。

## 模块类型建议

| 模块 | 典型输出 |
|------|----------|
| Settings | ProviderConfig types、settingsStore、SettingsView、Go Bridge config read/write |
| ProductInput | ProductContext types、上传组件、图片元信息读取、Go Bridge SaveUploadedImage |
| PromptBuilder | prompt types、平台规则常量、规则函数、测试 |
| MainImageTask | MainImageTask types、generationJobStore、主图结果组件、Provider bridge 调用 |
| DetailSectionTask | DetailPagePlan、VisualStyleGuide、SectionStatus、DetailSectionsPanel |
| Composer | DetailComposerConfig、TextOverlay、Canvas preview、ExportEngine contract |
| History | historyStore、任务列表、打开文件夹 bridge 方法 |

## 强制约束

1. AI Provider 模块必须走 Go Bridge Provider Adapter。
2. 不生成前端直连 `fetch(baseUrl)` 的 AI Gateway 代码。
3. 本地文件路径由 Go Bridge 返回，不在前端拼接 Windows/macOS 绝对路径。
4. API Key 不进入 props、store history、job 文件、测试快照或日志。
5. 详情长图相关模块必须支持 section 状态和单段重试。
6. Composer 模块必须区分 Canvas 预览/轻量导出和 Go Image Composer 兜底。

## 使用方式

```text
@claude 为 AI Provider 设置创建桌面端模块
@claude 为 ProductInput 创建商品图上传和 ProductContext 模块
@claude 为 MainImageTask 创建主图生成模块
@claude 为 DetailSectionTask 创建 quick4 分段生成模块
@claude 为 Composer 创建详情长图预览和导出模块
```

## 输出示例

```text
desktop/frontend/src/types/<module>.ts
desktop/frontend/src/stores/<module>.ts
desktop/frontend/src/services/bridge/<module>Bridge.ts
desktop/frontend/src/composables/use<Module>.ts
desktop/frontend/src/components/generation/<ModulePanel>.vue
desktop/frontend/src/views/<Module>View.vue
desktop/frontend/src/__tests__/<module>.spec.ts
```

如涉及 Go Bridge，可增加：

```text
desktop/app/<module>.go 或对应 Wails bridge 文件
desktop/app/<module>_test.go
```

## 后续云端说明

服务端 handler/service/repository 脚手架不属于当前桌面 MVP 范围，仅在用户明确要求服务端接口时生成。

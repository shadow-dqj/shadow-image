# full-feature-dev

## 描述

从需求确认到实现的完整功能开发工作流，使用多 Agent 编排。当前 MVP 主要用于桌面端电商 AI 商品图生成能力：主图闭环、详情长图 quick4/full8、Go Bridge Provider Adapter、本地保存与跨平台导出。

## 阶段

1. **Understand** — 并行阅读相关产品、架构、工程文档和现有代码。
2. **Design** — 设计桌面端功能方案，先定契约再实现。
3. **Implement** — 生成 TypeScript 类型、Store、Bridge Service、Vue 组件、Go Bridge 合约和测试。
4. **Verify** — type-check/lint/test/build、必要时 Wails/Go Bridge 验证和代码审查。

## Agent 编排

### Phase 1: Understand

- Agent 1: 阅读 [PRD](../../docs/product/PRD.md)，确认产品范围和 MVP-A/B/C 优先级。
- Agent 2: 阅读 [AI Agent 作图业务流程](../../docs/product/agent-image-workflow.md)，确认主图 + 详情长图 Agent 工作流。
- Agent 3: 阅读 [桌面端工程落地方案](../../docs/architecture/desktop-generation-architecture.md)，确认 Go Bridge、Provider Adapter、本地目录、状态机和导出兜底。
- Agent 4: 阅读相关 Vue/TypeScript/Wails/Go 现有代码。

### Phase 2: Design

综合 Phase 1 结果，输出变更设计，必须明确：

- 目标阶段：MVP-A 主图闭环 / MVP-B quick4 / MVP-C full8。
- 页面和组件。
- TypeScript types。
- Pinia store 或 composable。
- Wails bridge service 前端调用边界。
- Go Bridge contract / Provider Adapter contract。
- PromptBuilder / PlatformRules / VisualStyleGuide 规则。
- 本地文件和 JSON 落盘路径。
- 任务状态机和错误状态。
- 测试策略和验证命令。

### Phase 3: Implement

#### MVP-A：主图闭环

- Step 0: 检查当前前端/Wails 脚手架和用户请求范围。
- Step 1: Settings + ProviderConfig + 网络/代理配置。
- Step 2: Go Bridge AppData/文件系统封装。
- Step 3: ProductInput + ProductContext。
- Step 4: PlatformTarget + GenerationPackage。
- Step 5: PromptBuilder 本地规则版。
- Step 6: Go Bridge Provider Adapter 基础调用。
- Step 7: MainImageTask 主图生成闭环。
- Step 8: LocalHistory JSON 保存。

#### MVP-B：详情长图 quick4

- Step 9: DetailPagePlan quick4 模板。
- Step 10: VisualStyleGuide。
- Step 11: DetailSectionTask 状态机。
- Step 12: 分段生成和单段重试。
- Step 13: DetailComposer Canvas 预览。
- Step 14: ExportEngine + Go Image Composer 兜底设计。

#### MVP-C：详情长图 full8

- Step 15: full8 模板。
- Step 16: 本地文字/参数表/图标图层。
- Step 17: 导出包。
- Step 18: Windows/macOS 打包验证。

除非用户明确要求，不做服务端接口、云端后台、积分、订阅、服务端队列或服务端数据库。

### Phase 4: Verify

- Agent 1: 运行前端 type-check/lint/test/build。
- Agent 2: 如涉及 Go/Wails，检查 Go Bridge contract、Wails binding 或 Go 构建。
- Agent 3: 代码审查。
- Agent 4: 安全与跨平台检查：API Key 脱敏、前端不直连 AI Gateway、路径不写死、任务可恢复、导出有兜底。

## 强制约束

1. 前端 WebView 不直接请求用户配置的 AI Gateway。
2. AI API 请求、图片下载、base64 解码、代理、超时和错误归一化必须走 Go Bridge Provider Adapter。
3. AppData、项目目录、任务目录、打开文件夹由 Go Bridge 管理。
4. API Key 不写入任务文件、历史文件、错误摘要或导出包。
5. 详情长图必须分段生成，不一次性生成完整长图。
6. 文字、参数表、图标、标注优先本地叠加。
7. Fabric.js/Canvas 负责预览和轻量编辑；超长图最终导出预留 Go Image Composer。

## 使用方式

```text
@claude 实现 AI Provider 设置页，使用 full-feature-dev 工作流
@claude 实现 MVP-A 主图闭环，使用 full-feature-dev 工作流
@claude 实现 quick4 详情长图分段生成，使用 full-feature-dev 工作流
@claude 实现 DetailComposer 导出引擎，使用 full-feature-dev 工作流
```

## 前置条件

- 功能描述已在 PRD、Agent 工作流或桌面工程方案中定义。
- `desktop/frontend/package.json` 存在。
- 如涉及 Go Bridge，需确认 Wails/Go 代码结构。
- 如涉及访问凭证保存，必须确认不提交真实凭证、不在日志泄露。

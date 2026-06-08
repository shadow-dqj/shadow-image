# MVP 开发任务路线图

## 目标

本文档用于把产品方案、Agent 工作流和桌面端工程方案拆解为可执行开发任务，作为 Claude/Agent 辅助开发时的长期进度基准。

关联文档：

- [产品需求文档](../product/PRD.md)
- [AI Agent 作图业务流程](../product/agent-image-workflow.md)
- [桌面端主图 + 详情长图工程落地方案](../architecture/desktop-generation-architecture.md)
- [Workflows 索引](../../workflows/README.md)

## 任务状态规则

| 状态 | 含义 |
|------|------|
| `todo` | 未开始 |
| `doing` | 正在开发 |
| `blocked` | 被依赖、技术问题或需求不清阻塞 |
| `review` | 已实现，等待验证/审查 |
| `done` | 已实现、已验证、已同步文档 |
| `deferred` | 暂缓，不进入当前阶段 |

## 进度更新机制

### 短期会话内

使用 Claude 会话任务列表跟踪当前正在处理的 3-8 个小任务：

```text
TaskCreate → 创建当前会话任务
TaskUpdate doing → 开始处理
TaskUpdate done → 完成处理
```

适合：当前会话内的实现、验证和修复。

### 长期项目进度

使用本文档作为长期进度源。每完成一个路线图任务，必须同步：

1. 将状态改为 `done`。
2. 填写或更新“实现记录”。
3. 填写验证结果。
4. 如有提交，记录 commit hash。
5. 如任务范围变化，更新依赖和验收标准。

### 是否需要 skill

默认不需要专门 skill。Claude 可以在完成任务后直接编辑本文档更新状态。

只有当需要“每次完成某类动作后自动触发更新/提醒/命令”的自动化行为时，才需要配置 Claude Code hooks/settings；这类配置应使用 `update-config` skill 处理。

## 开发总原则

1. 按 MVP-A → MVP-B → MVP-C 顺序推进。
2. 每次只实现一个可验证小闭环。
3. AI API 请求必须走 Go Bridge Provider Adapter。
4. 前端 WebView 不直接请求用户配置的 AI Gateway。
5. API Key 不进入任务文件、历史、日志、错误摘要或导出包。
6. 本地路径由 Go Bridge 管理，不写死 Windows/macOS 绝对路径。
7. 详情长图必须分段生成、统一 VisualStyleGuide、本地拼接。
8. 分段失败只重试当前段。
9. Canvas/Fabric.js 负责预览和轻量编辑，超长图导出预留 Go Image Composer。
10. 阶段完成后运行验证和综合审查。

## MVP-A：主图闭环

目标：跑通桌面端最小价值闭环。

```text
配置 AI Provider
→ 上传商品图
→ 生成 ProductContext
→ 选择平台/生成套餐
→ PromptBuilder 生成主图 Prompt
→ Go Bridge Provider Adapter 调用 AI API
→ 预览主图
→ 保存/导出
→ 写入历史
```

| ID | 任务 | 状态 | 依赖 | 交付物 | 验收标准 |
|----|------|------|------|--------|----------|
| A1 | 检查/补齐桌面工程结构 | done | - | 工程结构检查记录；必要的目录/入口调整 | 确认 `desktop/frontend`、Wails/Go Bridge 入口、脚本和构建方式 |
| A1.5 | 补齐 Wails 打包流水线 | done | A1 | Taskfile、生产资产嵌入、Windows exe 构建记录 | `wails3 build` 可先构建前端，再生成 Windows 桌面 exe |
| A2 | 实现 Settings + ProviderConfig + 网络/代理配置 | todo | A1,A1.5 | SettingsView、settingsStore、ProviderConfig 类型 | 可保存/读取 Base URL、API Key、Model、Provider Type、timeout、proxy；API Key 脱敏 |
| A3 | 实现 Go Bridge AppData/文件系统封装 | todo | A1 | Go Bridge 文件方法、前端 bridge client | 可获取 AppData、创建项目/任务目录、保存文件、打开文件夹，路径跨平台 |
| A4 | 实现 ProductInput + ProductContext | todo | A3 | ProductInputPanel、ProductContext 类型、上传保存逻辑 | 可上传 jpg/png/webp，复制到项目目录，读取尺寸/大小/mime，生成 ProductContext |
| A5 | 实现 PlatformTarget + GenerationPackage | todo | A1 | 平台规则常量、GenerationPackage 类型、TargetPackagePanel | 可选择平台、图片类型、主图/详情/主图+详情生成套餐 |
| A6 | 实现 PromptBuilder 本地规则版 | todo | A4,A5 | PromptBuilder、NegativePrompt、测试 | 可根据 ProductContext + PlatformTarget 生成主图 Prompt；测试覆盖商品保持规则 |
| A7 | 实现 Go Bridge Provider Adapter 基础调用 | todo | A2,A3,A6 | Provider Adapter、testConnection、generateImage mock/真实接口边界 | 外部请求走 Go Bridge；支持 response url/base64；错误归一化；不泄露 API Key |
| A8 | 实现 MainImageTask 主图生成闭环 | todo | A4,A5,A6,A7 | generationJobStore、MainImageResultPanel、主图状态机 | 可发起主图生成、显示 loading/error/result，失败可重试 |
| A9 | 实现 LocalHistory JSON 保存 | todo | A3,A8 | historyStore、history.json schema、HistoryView 初版 | 主图生成记录可保存和展示；记录不包含 API Key |
| A10 | 实现主图导出 | todo | A3,A8 | ExportPanel、导出方法 | 可按平台规格保存主图，打开导出目录 |

### MVP-A 验证

完成 A1-A10 后必须运行：

```text
workflows/dev/dev-verify-loop.md
workflows/review/comprehensive-review.md
```

MVP-A 完成标准：

```text
用户可以配置 AI Provider
→ 上传一张商品图
→ 生成主图 Prompt
→ 调用用户配置的 AI API
→ 预览结果
→ 保存/导出主图
→ 历史记录可见
```

## MVP-B：详情长图 quick4

目标：验证详情长图分段生成、本地拼接和单段重试核心工作流。

```text
ProductContext
→ quick4 DetailPagePlan
→ VisualStyleGuide
→ 4 个 SectionPrompt
→ 分段生成
→ 单段重试
→ Canvas/Fabric.js 拼接预览
→ 导出 quick4 长图
```

| ID | 任务 | 状态 | 依赖 | 交付物 | 验收标准 |
|----|------|------|------|--------|----------|
| B1 | 实现 DetailPagePlan quick4 模板 | todo | A4,A5 | quick4 模板、DetailPagePlan 类型、测试 | 生成首屏卖点、场景展示、核心卖点、参数/包装 4 段计划 |
| B2 | 实现 VisualStyleGuide 默认生成/编辑 | todo | A4,A5 | VisualStyleGuide 类型、默认规则、编辑 UI | 详情各段可共享统一色彩、光影、背景、排版规则 |
| B3 | 实现 SectionPromptBuilder | todo | B1,B2,A6 | 分段 PromptBuilder、section-prompts.json | 每段 Prompt 继承 ProductContext、VisualStyleGuide、段落目标和文字留白规则 |
| B4 | 实现 DetailSectionTask 状态机 | todo | B1 | SectionStatus、状态流、测试 | 支持 planned/prompt_ready/generating/reviewing/approved/retry_needed/failed |
| B5 | 实现分段生成 | todo | A7,B3,B4 | DetailSectionsPanel、分段生成 action | 可顺序生成 4 段详情图，每段独立保存 |
| B6 | 实现单段重试 | todo | B4,B5 | retry section action、UI 操作 | 单段失败只重试当前段，复用同一 VisualStyleGuide |
| B7 | 实现分段结果保存 | todo | A3,B5 | sections 文件目录、section-reviews.json | 每段图片和状态立即落盘，应用重开可恢复 |
| B8 | 实现 DetailComposer Canvas 预览 | todo | B5,B7 | DetailComposerPanel、ComposerConfig | 可按顺序纵向预览 4 段详情图和本地文字占位 |
| B9 | 实现 quick4 长图导出 | todo | B8,A10 | ExportEngine canvas_export 初版 | 可导出 quick4 detail-long-image.png |
| B10 | 设计 Go Image Composer 兜底接口 | todo | B8,B9 | Go Image Composer contract、导出配置 | 明确超长图导出输入/输出，预留 Go 后端实现路径 |

### MVP-B 验证

完成 B1-B10 后必须运行：

```text
workflows/dev/dev-verify-loop.md
workflows/review/comprehensive-review.md
```

MVP-B 完成标准：

```text
用户可以基于同一商品图生成 4 段详情图
→ 每段可单独重试
→ 分段图可本地保存
→ 可拼接成 quick4 详情长图
```

## MVP-C：详情长图 full8 + 编辑增强

目标：形成正式电商详情页草案能力。

```text
quick4
+ 卖点段 2
+ 材质/细节段
+ 使用步骤段
+ 包装/适用人群段
→ full8 长图
→ 本地文字/参数/图标/标注编辑
→ 导出包
→ Windows/macOS 打包验证
```

| ID | 任务 | 状态 | 依赖 | 交付物 | 验收标准 |
|----|------|------|------|--------|----------|
| C1 | 实现 full8 模板 | todo | B1 | full8 DetailPagePlan | 生成 8 段详情页计划，与产品方案一致 |
| C2 | 实现 TextOverlay 图层模型 | todo | B8 | TextOverlay 类型、图层 store | 支持 title/subtitle/body/badge/spec_table/step_number/annotation |
| C3 | 实现标题/卖点/参数表本地叠加 | todo | C2 | 本地文字和参数表 UI | 可编辑详情长图文字，不依赖模型生成可读文字 |
| C4 | 实现图标/步骤编号/标注线 | todo | C2 | 图标/步骤/标注图层 | 可添加步骤编号、标注线和简单图标 |
| C5 | 实现 ExportEngine 完整导出包 | todo | B9,C2 | 导出主图、长图、分段素材、JSON 记录 | 导出包包含图片、style-guide、section-prompts、text-overlays、summary |
| C6 | 实现 Go Image Composer 兜底 | todo | B10,C5 | Go 导出实现或可运行原型 | 超长图可由 Go 后端稳定拼接导出 |
| C7 | 实现历史复用 | todo | A9,C5 | 历史详情、Prompt 复用、重新生成入口 | 可从历史任务复制 Prompt 或重新生成某段 |
| C8 | Windows 打包验证 | todo | C5 | Windows 构建记录 | Windows x64 可启动、配置、上传、导出 |
| C9 | macOS 打包验证 | deferred | C5 | macOS 构建记录 | macOS arm64/amd64 可启动、配置、上传、导出 |

### MVP-C 验证

完成 C1-C9 后必须运行：

```text
workflows/dev/dev-verify-loop.md
workflows/review/comprehensive-review.md
```

MVP-C 完成标准：

```text
用户可以生成完整 8 段详情长图草案
→ 本地修改文案/参数
→ 导出长图和分段素材
→ Windows/macOS 路径和导出逻辑可用
```

## 实现记录

每完成一个任务，在这里追加记录：

```text
2026-06-08
- 任务：A1 检查/补齐桌面工程结构
- 状态：done
- 实现文件：desktop/go.mod、desktop/go.sum、desktop/main.go、desktop/app_service.go、desktop/app_service_test.go、desktop/frontend/package-lock.json、desktop/frontend/tsconfig.json、desktop/frontend/eslint.config.ts、desktop/frontend/src/App.vue、desktop/frontend/src/components/HealthCard.vue、desktop/frontend/src/__tests__/HealthCard.spec.ts、docs/development/environment-setup.md
- 验证：desktop/frontend npm run type-check/lint/test/build 通过；desktop go test . 通过；Wails CLI 当前环境未安装，桌面运行/打包验证留待后续环境任务
- Commit：待提交
- 备注：已补齐最小 Wails v3 Go 入口和 AppData Bridge 服务；main.go 暂用 Wails AlphaAssets 保持 clean checkout 下可编译，后续 Wails build task 再接入 Vite dist 嵌入产物。

2026-06-08
- 任务：A1.5 补齐 Wails 打包流水线
- 状态：done
- 实现文件：desktop/Taskfile.yml、desktop/assets_dev.go、desktop/assets_prod.go、desktop/main.go、desktop/frontend/eslint.config.ts、docs/development/mvp-implementation-roadmap.md
- 验证：desktop/frontend npm run type-check/lint/test/build 通过；desktop go test . 通过；PATH=/d/Go/bin:$PATH wails3 build 通过并生成 desktop/bin/shadow-image.exe
- Commit：待提交
- 备注：开发/测试默认使用 Wails AlphaAssets，production build tag 嵌入 frontend/dist；wails3 build 通过 Taskfile 串联 npm install、npm run build 和 go build -tags production。
```

## 当前下一步

当前建议进入 `A2 实现 Settings + ProviderConfig + 网络/代理配置`。

A2 需要确认：

- SettingsView 和 settingsStore 的模块位置。
- ProviderConfig 类型包含 Base URL、API Key 引用、Model、Provider Type、timeout、proxy。
- API Key UI 脱敏展示，不进入日志、任务文件或测试快照。
- 设置读写最终通过 Go Bridge；如先做前端 mock，需要明确替换边界。
- 测试覆盖默认值、脱敏和配置校验。

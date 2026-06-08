# 桌面端主图 + 详情长图工程落地方案

## 目标

本文档把产品侧的“上传一张商品图 → 自动生成主图 + 详情长图草案”方案落实为桌面端可开发架构，作为进入开发调研和任务拆分前的工程基准。

关联文档：

- [产品需求文档](../product/PRD.md)
- [AI Agent 作图业务流程](../product/agent-image-workflow.md)
- [系统架构设计](system-design.md)
- [技术栈决策](tech-stack.md)

## 工程边界

MVP 是本地桌面工具，不建设云端后台、用户体系、积分计费、服务端队列和服务端数据库。

```text
Wails Desktop App
├── Vue 3 + TypeScript + Element Plus UI
├── Pinia 本地状态
├── Fabric.js / Canvas 预览与轻量编辑
├── Go Bridge 本地文件系统、外部 API 请求、导出兜底
└── 用户配置的 AI Gateway / OpenAI-compatible API
```

跨平台目标：优先支持 Windows x64、macOS arm64、macOS amd64，后续按发布需要提供 macOS Universal 包。

核心落地目标：

1. 单个商品参考图作为一次生成任务的唯一商品主体来源。
2. 一次任务可以生成主图、详情长图，或两者同时生成。
3. 详情长图采用 4 段快速版或 8 段完整版，分段生成、本地拼接。
4. 所有生成产物、Prompt、Style Guide、分段状态和导出摘要保存在本地。
5. 支持单段失败重试，避免整张长图重新生成。
6. AI Provider 差异通过 Go Bridge 中的 Provider Adapter 处理，不散落在页面组件中。
7. 所有外部 AI API 请求必须经由 Go Bridge 发起，前端 WebView 不直接请求用户配置的 AI Gateway。
8. 本地路径、AppData 目录、打开文件夹和导出路径由 Go Bridge 统一管理，前端不写死 Windows/macOS 路径。

## 跨平台实现约束

### 平台与运行时

| 平台 | 目标 | 关键依赖/注意事项 |
|------|------|------------------|
| Windows | Windows x64 优先 | 依赖 WebView2 Runtime；需要处理安装包、代码签名、杀软误报、代理和防火墙提示 |
| macOS | arm64 / amd64 | 使用系统 WebView；需要处理 Gatekeeper、代码签名、Notarization、本地文件访问和 Keychain 权限 |
| macOS Universal | 发布增强 | 分别构建 arm64/amd64 后合并，适合正式分发 |

MVP 可以先在当前开发机完成 Windows 包验证，后续通过 macOS runner 或真实 macOS 设备验证 macOS 包。

### Go Bridge 强约束

跨平台落地时，Go Bridge 不只是文件桥接层，还应承担以下职责：

1. 统一管理 AppData 目录和项目目录。
2. 统一发起外部 AI API 请求，避免前端 WebView 直接请求导致 CORS、密钥暴露和响应处理复杂。
3. 统一处理 HTTP 超时、代理、TLS、下载图片、base64 解码和错误归一化。
4. 统一保存上传图、生成图、任务 JSON、导出文件。
5. 统一打开文件夹和暴露本地预览 URL。
6. 为超长详情图提供 Go Image Composer 导出兜底。

### AppData 目录策略

本地数据根目录必须由 Go Bridge 获取和返回，前端不能写死路径。

```text
Windows: %AppData%/ShadowImage
macOS: ~/Library/Application Support/ShadowImage
```

建议 Go Bridge 暴露：

```go
GetAppDataDir()
GetProjectDir(projectID string)
GetJobDir(projectID string, jobID string)
SaveUploadedImage(...)
SaveGeneratedImage(...)
WriteJobFile(...)
OpenInFileManager(path string)
```

前端只保存逻辑路径、本地文件 ID 或 Go Bridge 返回的可预览 URL。

### 网络与代理

Settings 中应预留网络配置：

| 配置项 | 说明 |
|--------|------|
| useSystemProxy | 是否使用系统代理 |
| customProxyUrl | 自定义 HTTP/HTTPS 代理 |
| requestTimeoutMs | 请求超时 |
| retryCount | 用户触发重试的默认次数上限，不做无限自动重试 |

网络请求由 Go Bridge Provider Adapter 读取这些配置并执行。

### API Key 存储

| 阶段 | 存储策略 |
|------|----------|
| MVP | 本地 `settings.json` 保存，UI 脱敏展示，不写入任务文件/导出包/日志 |
| Beta | 本地简单加密或凭证迁移提醒 |
| 正式版 | Windows Credential Manager / macOS Keychain |

无论哪个阶段，API Key 都不得写入：

- `job.json`
- `history.json`
- `export-summary.json`
- 错误摘要
- 导出包

### 字体与导出一致性

详情长图需要本地叠加中文/英文文字。Windows 和 macOS 默认字体不同，导出效果可能不一致。

MVP 可先使用系统字体栈：

```text
Windows: Microsoft YaHei / Segoe UI
macOS: PingFang SC / San Francisco
```

正式版建议内置导出字体，例如：

```text
export-fonts/
├── NotoSansSC-Regular.otf
└── NotoSansSC-Bold.otf
```

如果后续使用 Go Image Composer 渲染文字，需要由 Go 层加载内置字体文件，避免跨平台字体差异导致版式偏移。

## 桌面端页面流

### 页面结构

```text
SettingsView
  └── AI Provider 设置、连接测试、默认尺寸/质量

GenerateWorkspaceView
  ├── ProductInputPanel
  ├── TargetPackagePanel
  ├── GenerationPlanPanel
  ├── PromptReviewPanel
  ├── MainImageResultPanel
  ├── DetailSectionsPanel
  ├── DetailComposerPanel
  └── ExportPanel

HistoryView
  └── 历史任务、输出文件、Prompt 复用、打开文件夹
```

### 用户操作流程

```text
1. 首次进入 SettingsView
   → 填写 Base URL / API Key / Model / Provider Type
   → 测试连接

2. 进入 GenerateWorkspaceView
   → 上传一张商品参考图
   → 填写商品名称、类目、卖点、禁忌项
   → 选择平台和生成套餐

3. 生成任务规划
   → 创建 ProductContext
   → 创建 AutoGenerationJob
   → 若包含详情长图，生成 DetailPagePlan
   → 生成或确认 VisualStyleGuide

4. Prompt 确认
   → 生成主图 Prompt
   → 生成详情分段 Prompt
   → 用户可编辑确认

5. 图片生成
   → 生成主图
   → 逐段生成详情图
   → 每段独立显示状态

6. 质检与重试
   → 主图质检
   → 详情分段质检
   → 不合格段落可单独重试

7. 本地拼接与编辑
   → 本地添加标题、图标、参数表、标注线
   → 拼接详情长图
   → 进入轻量编辑

8. 导出归档
   → 导出主图
   → 导出详情长图
   → 导出分段素材和 JSON 记录
   → 写入 History
```

## 前端模块建议

```text
desktop/frontend/src/
├── views/
│   ├── SettingsView.vue
│   ├── GenerateWorkspaceView.vue
│   └── HistoryView.vue
├── components/generation/
│   ├── ProductInputPanel.vue
│   ├── TargetPackagePanel.vue
│   ├── GenerationPlanPanel.vue
│   ├── PromptReviewPanel.vue
│   ├── MainImageResultPanel.vue
│   ├── DetailSectionsPanel.vue
│   ├── DetailComposerPanel.vue
│   └── ExportPanel.vue
├── stores/
│   ├── settingsStore.ts
│   ├── generationJobStore.ts
│   ├── providerStore.ts
│   └── historyStore.ts
├── services/
│   ├── bridge/
│   ├── prompt/
│   ├── generation/
│   ├── composer/
│   ├── export/
│   └── localStorage/
└── types/
    ├── product.ts
    ├── generation.ts
    ├── provider.ts
    ├── detail.ts
    └── export.ts
```

## 核心数据模型

### ProductContext

```ts
interface ProductContext {
  sourceImagePath: string
  productName: string
  category?: string
  sellingPoints: string[]
  preserveRules: string[]
  forbiddenRules: string[]
  imageMeta: {
    width: number
    height: number
    sizeBytes: number
    mimeType: string
  }
}
```

### AutoGenerationJob

```ts
type GenerationPackage = 'main_only' | 'detail_only' | 'main_and_detail'

type JobStatus =
  | 'draft'
  | 'planning'
  | 'prompt_ready'
  | 'generating_main'
  | 'generating_detail'
  | 'reviewing'
  | 'composing'
  | 'editable'
  | 'exported'
  | 'failed'
  | 'cancelled'

interface AutoGenerationJob {
  jobId: string
  projectId?: string
  package: GenerationPackage
  productContext: ProductContext
  platformTarget: PlatformTarget
  stylePreference?: string
  visualStyleGuide?: VisualStyleGuide
  mainImageTask?: MainImageTask
  detailLongImageTask?: DetailLongImageTask
  status: JobStatus
  createdAt: string
  updatedAt: string
}
```

### PlatformTarget

```ts
type Platform = 'amazon' | 'shopify' | 'tiktok' | 'douyin' | 'xiaohongshu' | 'detail_page'

type ImageType =
  | 'white_background_main'
  | 'shopify_product'
  | 'lifestyle_scene'
  | 'vertical_ad'
  | 'social_cover'
  | 'detail_long_image'

interface PlatformTarget {
  platform: Platform
  imageType: ImageType
  recommendedSize: {
    width: number
    height: number
  }
  aspectRatio: string
  rules: string[]
}
```

### MainImageTask

```ts
interface MainImageTask {
  taskId: string
  prompt: string
  negativePrompt: string
  params: GenerationParams
  status: SectionStatus
  outputPath?: string
  review?: QualityReviewResult
  mainVisualAnchor?: MainVisualAnchor
}

interface MainVisualAnchor {
  dominantColors: string[]
  lighting: string
  backgroundStyle: string
  productPlacement: string
  mood: string
}
```

### DetailLongImageTask

```ts
type DetailMode = 'quick4' | 'full8'

type SectionStatus =
  | 'planned'
  | 'prompt_ready'
  | 'generating'
  | 'generated'
  | 'reviewing'
  | 'approved'
  | 'retry_needed'
  | 'edit_needed'
  | 'failed'
  | 'cancelled'

interface DetailLongImageTask {
  taskId: string
  mode: DetailMode
  sectionPlan: DetailPagePlan
  sections: DetailSectionTask[]
  composerConfig?: DetailComposerConfig
  outputPath?: string
  status: JobStatus
}

interface DetailPagePlan {
  mode: DetailMode
  sections: DetailSectionPlan[]
}

interface DetailSectionPlan {
  id: string
  order: number
  title: string
  goal: string
  visualType: string
  targetHeight: number
  copySlots: string[]
}

interface DetailSectionTask {
  sectionId: string
  plan: DetailSectionPlan
  prompt: string
  negativePrompt: string
  params: GenerationParams
  status: SectionStatus
  outputPath?: string
  retryCount: number
  review?: QualityReviewResult
}
```

### VisualStyleGuide

```ts
interface VisualStyleGuide {
  colorPalette: {
    primary: string
    secondary: string
    accent: string
    background: string
  }
  backgroundStyle: string
  lighting: string
  composition: string
  typography: {
    title: string
    body: string
  }
  iconStyle: string
  spacing: string
  preserveRules: string[]
  forbiddenRules: string[]
}
```

### GenerationParams

```ts
interface GenerationParams {
  model: string
  size: string
  quality?: 'standard' | 'high'
  timeoutMs: number
  providerType: ProviderType
  requestMode: ProviderRequestMode
}
```

## 本地文件与目录结构

MVP 可先使用 JSON 文件 + 本地目录保存，后续历史复杂后再升级 SQLite。目录根路径由 Go Bridge 根据平台获取：Windows 使用 `%AppData%/ShadowImage`，macOS 使用 `~/Library/Application Support/ShadowImage`。

```text
ShadowImageData/
├── settings.json
├── prompt-presets.json
├── platform-rules.json
├── projects/
│   └── <projectId>/
│       ├── project.json
│       ├── product/
│       │   └── source.png
│       ├── jobs/
│       │   └── <jobId>/
│       │       ├── job.json
│       │       ├── product-context.json
│       │       ├── visual-style-guide.json
│       │       ├── main/
│       │       │   ├── main-image.png
│       │       │   ├── main-prompt.json
│       │       │   └── main-review.json
│       │       ├── detail/
│       │       │   ├── section-plan.json
│       │       │   ├── section-prompts.json
│       │       │   ├── sections/
│       │       │   │   ├── 01-hero.png
│       │       │   │   ├── 02-scene.png
│       │       │   │   ├── 03-benefit-a.png
│       │       │   │   └── ...
│       │       │   ├── section-reviews.json
│       │       │   ├── text-overlays.json
│       │       │   └── detail-long-image.png
│       │       └── export-summary.json
│       └── history.json
└── exports/
    └── <date-or-project>/
```

### 保存策略

1. 用户上传图片时，复制一份到项目目录，避免原路径移动后任务失效。
2. 每次生成任务写入 `job.json`，用于中断恢复。
3. 每段详情图生成完成后立即保存文件和状态。
4. 导出文件和任务内部素材分开保存，避免用户清理导出时破坏历史。
5. API Key 不写入任务文件，只保存在设置中并脱敏展示。

## AI Provider 适配层

### Provider 类型

```ts
type ProviderType = 'openai_compatible' | 'custom_gateway'

type ProviderRequestMode =
  | 'text_to_image'
  | 'image_to_image'
  | 'image_edit'
  | 'multi_image_reference'
```

### Go Bridge Provider Adapter

所有外部 AI API 请求由 Go Bridge 中的 Provider Adapter 发起，Vue 前端只提交生成请求参数并接收任务状态/本地文件路径。这样可以避免 WebView CORS、减少 API Key 暴露面，并统一处理 Windows/macOS 网络、代理、TLS、超时和文件保存差异。

```text
Vue UI
→ Wails Go Bridge
→ Provider Adapter
→ User AI Gateway
→ Go 保存图片到本地
→ Vue 接收本地预览 URL / outputPath
```

### 统一接口

```ts
interface ProviderConfig {
  providerType: ProviderType
  baseUrl: string
  apiKeyRef: string
  model: string
  timeoutMs: number
  useSystemProxy: boolean
  customProxyUrl?: string
}

interface ImageGenerationProvider {
  testConnection(config: ProviderConfig): Promise<ProviderTestResult>
  getCapabilities(config: ProviderConfig): Promise<ProviderCapabilities>
  generateImage(request: ImageGenerationRequest): Promise<ImageGenerationResult>
}
```

### 能力矩阵

| 能力 | MVP 必要性 | 影响 | 不支持时处理 |
|------|-----------|------|-------------|
| text-to-image | 可选 | 可生成测试图，但商品一致性弱 | 标记为不推荐真实商品图 |
| image-to-image | 强依赖 | 商品参考图可作为主体依据 | 禁用或警告主图/详情真实生成 |
| image edit | 强依赖 | 更适合保持商品主体并换背景 | 不支持时退化为 image-to-image |
| response url | P0 | 结果从 URL 下载 | 走下载保存流程 |
| response base64 | P0 | 结果直接写本地文件 | 走 base64 解码保存流程 |
| size 参数 | P0 | 控制主图/分段比例 | 使用默认尺寸并提示用户 |
| quality 参数 | P1 | 控制成本和效果 | 隐藏质量选项或映射默认值 |
| mask edit | P2 | 局部修改 | MVP 不依赖 |
| multi-reference | P2 | 多角度商品一致性 | MVP 不依赖 |

### 降级策略

如果当前 Provider 不支持商品参考图能力：

```text
1. UI 明确提示：当前模型无法稳定保持商品主体，不建议用于真实商品图。
2. 允许用户只生成 Prompt 草案或风格测试图。
3. 主图/详情长图真实生成按钮需要二次确认。
4. 后续可提供“本地抠商品 + AI 生成背景 + 本地合成”的降级路线。
```

如果响应格式无法识别：

```text
1. 保存原始错误摘要，不保存 API Key。
2. 显示用户可理解错误：鉴权失败、超时、模型不支持、响应缺少图片等。
3. 允许用户修改 Provider 设置后重试当前任务。
```

## Prompt 与规划服务

MVP 可以先使用本地规则版 Prompt Optimizer，不强依赖额外 LLM 文本接口。

```text
ProductContext
+ PlatformTarget
+ StylePreference
+ DetailPagePlan
+ VisualStyleGuide
→ PromptBuilder
→ MainImagePrompt / SectionPrompts / NegativePrompt
```

### PromptBuilder 职责

1. 拼接商品保持规则。
2. 拼接平台规则和尺寸要求。
3. 拼接用户风格偏好。
4. 拼接统一 VisualStyleGuide。
5. 为每个详情段落生成独立 Section Prompt。
6. 输出用户可编辑版本。

### 详情大纲来源

MVP 阶段默认使用本地模板：

- `quick4`：首屏卖点、场景展示、核心卖点、参数/包装。
- `full8`：首屏、场景、卖点 A、卖点 B、材质细节、使用步骤、参数规格、包装/适用人群。

后续可升级为 AI Planner，根据商品类目自动增删段落。

## 生成任务状态机

### Job 状态流

```text
draft
→ planning
→ prompt_ready
→ generating_main
→ generating_detail
→ reviewing
→ composing
→ editable
→ exported
```

异常状态：

```text
failed
cancelled
```

### Section 状态流

```text
planned
→ prompt_ready
→ generating
→ generated
→ reviewing
→ approved
```

可恢复状态：

```text
retry_needed
edit_needed
failed
cancelled
```

### 中断恢复

桌面软件需要支持任务恢复：

1. 应用关闭或崩溃后，重新打开时读取 `job.json`。
2. 已生成的主图和分段图不重复请求。
3. 未完成段落可继续生成。
4. 失败段落可单独重试。
5. 如果 Provider 配置已变更，继续任务前提示用户确认。

## 详情长图 Composer

### MVP Composer 路线

MVP 中 Fabric.js / Canvas 优先负责**拼接预览、图层编辑和轻量导出**。由于 Windows WebView2 和 macOS WebView 对超大 Canvas 的尺寸/内存限制可能不同，工程上必须预留 Go Image Composer 作为最终长图导出兜底。

```text
DetailSectionTask[]
+ DetailComposerConfig
+ text-overlays.json
→ Canvas/Fabric.js layout
→ preview / edit
→ ExportEngine
   ├── canvas_export      轻量导出
   └── go_image_export    超长图稳定导出兜底
→ detail-long-image.png
```

建议导出引擎类型：

```ts
type ExportEngine = 'canvas_export' | 'go_image_export'
```

Go Image Composer 输入：

```text
分段图片路径
+ composer-config.json
+ text-overlays.json
+ 内置/系统字体配置
→ 纵向拼接
→ 渲染本地文字/图标/参数表
→ 输出 PNG/JPG/WebP
```

### ComposerConfig

```ts
interface DetailComposerConfig {
  canvasWidth: number
  sectionGap: number
  backgroundColor: string
  padding: {
    top: number
    right: number
    bottom: number
    left: number
  }
  textOverlays: TextOverlay[]
}

interface TextOverlay {
  id: string
  sectionId: string
  type: 'title' | 'subtitle' | 'body' | 'badge' | 'spec_table' | 'step_number' | 'annotation'
  content: string
  position: { x: number; y: number }
  style: Record<string, string | number>
}
```

### 拼接规则

1. 所有分段图片先缩放到统一宽度。
2. 段落按 `order` 顺序纵向排列。
3. 分段之间保留统一间距或背景过渡。
4. 文字、图标、参数表使用本地图层叠加。
5. 导出前检查总高度和内存风险；轻量尺寸可走 Canvas 导出，超长图必须走 Go Image Composer 兜底。

### 本地编辑边界

MVP 编辑能力：

- 调整文字内容。
- 拖动文字位置。
- 开关图标/标注/参数表图层。
- 替换某个详情分段图片。
- 重新拼接导出。

P1/P2 再考虑：

- 多图层模板。
- 智能对齐。
- 批量套版。
- 局部修图。

## 质量检查

### MVP 半自动质检

MVP 质检以规则检查 + 用户确认清单为主。

| 检查项 | MVP 判断方式 |
|--------|--------------|
| 商品主体是否保持 | 用户肉眼确认 |
| Logo/包装文字是否异常 | 用户确认，后续可加 OCR |
| 尺寸比例是否符合平台 | 本地规则检查 |
| 是否留出文字空间 | 用户确认 |
| 是否出现乱码/水印 | 用户确认 |
| 是否已保存到本地 | 文件存在性检查 |

### 质检结果

```ts
interface QualityReviewResult {
  status: 'usable' | 'retry' | 'edit_needed' | 'rejected'
  issues: string[]
  reviewer: 'user' | 'rule' | 'ai_later'
  reviewedAt: string
}
```

## 错误处理与重试

### 常见错误

| 错误 | 用户提示 | 恢复动作 |
|------|----------|----------|
| API Key 无效 | 请检查 API Key 是否正确 | 返回设置页或重新测试连接 |
| Base URL 无法访问 | 请检查中转站地址和网络 | 修改配置后重试 |
| 模型不支持图片参考 | 当前模型可能无法保持商品主体 | 更换模型或继续生成测试图 |
| 请求超时 | 模型响应超时 | 增加超时时间或降低尺寸/质量 |
| 响应无图片 | 中转站返回格式不包含图片 | 查看原始错误摘要，调整 Provider 类型 |
| 单段生成失败 | 当前段落生成失败 | 单段重试 |
| Canvas 导出失败 | 长图尺寸过大或内存不足 | 降低宽度/段数，后续使用 Wails 后端导出 |

### 重试原则

1. 主图失败只重试主图。
2. 详情某段失败只重试该段。
3. 重试不修改 `VisualStyleGuide`，除非用户主动重新规划风格。
4. 连续失败时建议简化 Prompt 或降低生成尺寸。
5. 不做无限自动重试。

## 跨平台打包与发布

### 构建目标

| 目标 | 说明 |
|------|------|
| Windows x64 | MVP 首要验证目标，输出 exe/安装包 |
| macOS arm64 | Apple Silicon 设备 |
| macOS amd64 | Intel Mac 设备 |
| macOS Universal | 正式发布增强，合并 arm64/amd64 |

### 发布注意事项

Windows：

- 检查 WebView2 Runtime 依赖。
- 设置应用图标、应用名和用户数据目录。
- 后续增加代码签名，降低杀软误报。
- 处理防火墙、代理和 HTTPS 访问失败提示。

macOS：

- 分别验证 arm64 和 amd64。
- 正式发布需要代码签名和 Notarization。
- 文件访问、Keychain、网络访问需要真实设备验证。
- 如需要 Universal 包，使用 macOS 构建环境合并双架构产物。

### CI 建议

后续可使用平台原生 runner 构建：

```text
windows-latest → Windows x64
macos-latest   → macOS arm64/amd64/Universal
```

跨平台发布验证必须覆盖：

1. 启动应用。
2. 配置 Provider。
3. 上传商品图。
4. 调用 AI API 或 mock provider。
5. 保存生成结果。
6. 拼接并导出详情长图。
7. 打开导出目录。

## MVP 分阶段落地

### MVP-A：主图闭环

目标：先跑通桌面端最小价值闭环。

```text
Settings
→ 商品图上传
→ 平台/主图类型选择
→ Prompt 优化
→ 主图生成
→ 预览
→ 保存/导出
```

交付项：

- AI Provider 设置和测试连接。
- 商品参考图上传和预览。
- ProductContext。
- 主图 PromptBuilder。
- ImageGenerationProvider 基础适配。
- 主图保存和导出。
- 本地历史记录。

### MVP-B：详情长图快速版 4 段

目标：验证详情长图核心工作流。

```text
ProductContext
→ quick4 DetailPagePlan
→ VisualStyleGuide
→ 4 个 SectionPrompt
→ 分段生成
→ 单段重试
→ 本地拼接
→ 导出长图
```

交付项：

- DetailPagePlan quick4 模板。
- VisualStyleGuide 生成/编辑。
- DetailSectionsPanel。
- 分段状态机。
- 分段图片保存。
- 基础 Composer。
- detail-long-image.png 导出。

### MVP-C：详情长图完整版 8 段

目标：形成正式详情页草案能力。

```text
quick4
+ 卖点段 2
+ 材质/细节段
+ 使用步骤段
+ 包装/适用人群段
→ full8 长图导出
```

交付项：

- full8 模板。
- 每段文案槽位配置。
- text-overlays.json。
- 可替换分段图。
- 详情导出包。

### P1 后续增强

- AI Planner 自动生成详情大纲。
- OCR 检查包装文字是否被改。
- 商品主体一致性评分。
- Wails/Go 后端大图稳定导出。
- SQLite 历史库。
- Windows Credential Manager / macOS Keychain 保存 API Key。
- 批量 SKU 生成。

## 开发优先级建议

```text
1. Settings + ProviderConfig + 网络/代理配置
2. Go Bridge AppData/文件系统封装
3. ProductInput + ProductContext
4. PlatformTarget + GenerationPackage
5. PromptBuilder 本地规则版
6. Go Bridge Provider Adapter 基础调用
7. MainImageTask 主图闭环
8. LocalHistory JSON 保存
9. DetailPagePlan quick4
10. VisualStyleGuide
11. DetailSectionTask 状态机
12. 分段生成和重试
13. DetailComposer Canvas 预览
14. ExportEngine + Go Image Composer 兜底设计
15. ExportPackage 导出
16. full8 模板
17. Windows/macOS 打包验证
```

## 决策总结

1. 桌面端 MVP 继续坚持本地工具和 BYOK 模式。
2. 主图 + 详情长图是产品核心闭环。
3. 详情长图采用分段生成、本地拼接，不一次性生成完整长图。
4. MVP 使用本地模板规划详情页，AI Planner 后置。
5. Prompt、Style Guide、分段状态、导出记录都必须落盘。
6. Provider 能力不足时要明确降级提示，不能承诺商品一致性。
7. 所有外部 AI API 请求统一经由 Go Bridge Provider Adapter 发起。
8. Fabric.js/Canvas 负责预览和轻量编辑，最终超长图导出预留 Go Image Composer 兜底。
9. 本地路径、AppData、打开文件夹、导出路径由 Go Bridge 统一跨平台管理。
10. API Key MVP 本地脱敏保存，正式版升级 Windows Credential Manager / macOS Keychain。
11. 开发从主图闭环开始，再扩展 quick4，最后扩展 full8 和跨平台打包发布。

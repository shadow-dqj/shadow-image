# 系统架构设计

## MVP 整体架构

MVP 阶段采用**桌面端直连用户自有 AI 中转站/API**的架构，不建设云端管理后台和 SaaS 服务。

```text
┌─────────────────────────────────────────────────────────────┐
│                    Wails Desktop App                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Vue 3 UI     │  │ Fabric.js    │  │ Go Desktop Bridge │  │
│  │ Element Plus │  │ Preview/Edit │  │ FS/API/Export     │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         │                 │                   │            │
│         ├──────── Settings Store ─────────────┤            │
│         ├──────── Local History Store ────────┤            │
│         └──────── Local Assets/Outputs ───────┘            │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              User-configured AI Gateway / Model API          │
│  OpenAI-compatible endpoint / custom gateway / model relay    │
│  Base URL + API Key + Model are provided by the user locally  │
└─────────────────────────────────────────────────────────────┘
```

## 核心模块职责

### 桌面端 (Wails + Vue 3)

| 模块 | 职责 |
|------|------|
| Settings | AI Provider 配置：Base URL、API Key、Model、超时、默认尺寸/质量 |
| Upload | 商品参考图上传、格式校验、本地预览 |
| Prompt | 平台 Prompt 模板、Negative Prompt、用户编辑 |
| PromptOptimizer | 根据商品信息、平台规则、生成套餐和用户目标优化主图/详情分段 Prompt |
| PlatformRules | Amazon/Shopify/TikTok/抖音/小红书本地规则预设 |
| Generation | 调用用户配置的 AI 中转站/API，处理 loading、错误、分段重试、结果解析 |
| DetailWorkflow | 详情页大纲、VisualStyleGuide、分段生成状态、分段质检与本地拼接编排 |
| Canvas Editor | Fabric.js 画布，预览、裁剪、文字/Logo/图层叠加、详情长图拼接预览 |
| Go Image Composer | 超长详情图最终导出兜底，后续支持压缩、格式转换和大图稳定拼接 |
| History | 本地生成记录：原图、Prompt、模型、输出路径、时间 |
| Export | 按平台规格保存图片，打开输出目录 |
| Go Bridge | Wails 运行时、本地文件系统、配置读写、外部 AI API 请求、路径管理、后续 SQLite/Keychain 能力 |

## MVP 用户流程

```text
首次启动
→ 设置 AI Provider（Base URL / API Key / Model）
→ 测试连接
→ 上传一张商品参考图
→ 填写商品信息、卖点、风格和禁忌项
→ 选择平台和生成套餐（主图 / 详情长图 / 主图 + 详情长图）
→ 生成任务规划、详情页大纲和 VisualStyleGuide
→ 优化主图 Prompt / 详情分段 Prompt / Negative Prompt
→ Go Bridge Provider Adapter 直连用户配置的 AI Gateway
→ 展示主图和详情分段结果
→ 分段重试 / Fabric.js 轻量编辑 / 本地拼接 / 导出
```

## Prompt Optimizer

提示词优化模块位于 AI Provider 调用之前，负责将用户输入的商品信息和目标效果转换为稳定的电商生图 Prompt。

```text
ProductInfo + PlatformRules + GenerationPackage + UserIntent
  → PromptOptimizer
  → MainImagePrompt + SectionPrompts + NegativePrompt + GenerationParams
  → ImageGenerationProvider
```

### 输入

| 字段 | 说明 |
|------|------|
| productName | 商品名称 |
| category | 商品类目 |
| sellingPoints | 核心卖点 |
| platform | 目标平台 |
| imageType | 图片类型 |
| style | 目标风格 |
| userPrompt | 用户原始描述 |
| forbiddenChanges | 禁止改变项 |

### 输出

| 字段 | 说明 |
|------|------|
| optimizedPrompt | 优化后的生图 Prompt |
| negativePrompt | 负向 Prompt / 禁止项 |
| platformHints | 平台规则提示 |
| preserveRules | 商品主体保持规则 |
| suggestedParams | 尺寸、比例、质量等建议参数 |

### 规则

1. Prompt Optimizer 不直接调用生图接口。
2. 优化结果必须可编辑，用户确认后再生成。
3. 商品保持规则必须默认加入。
4. 平台规则必须参与 Prompt 和参数建议。
5. 不要求模型生成广告文字，广告文字优先留给 Fabric.js 后期编辑。

## AI Provider 适配层

建议在 Go Bridge 中抽象统一接口，前端不直接请求用户配置的 AI Gateway：

```text
ImageGenerationProvider
├── OpenAICompatibleProvider
└── CustomGatewayProvider
```

核心请求字段：

| 字段 | 说明 |
|------|------|
| baseUrl | 用户配置的 API 地址 |
| apiKey | 用户配置的密钥，本地保存和脱敏展示 |
| model | 用户配置的模型名 |
| prompt | 正向 Prompt |
| negativePrompt | 禁止项/负向 Prompt |
| referenceImage | 商品参考图 |
| size | 输出尺寸 |
| quality | 质量档位 |
| timeout | 超时时间 |

接口兼容策略：

1. 优先支持 OpenAI-compatible 图像接口。
2. 对中转站差异，通过 Provider Adapter 做字段映射。
3. 不把中转站差异散落到页面组件中。
4. 所有请求错误统一转换为用户可理解的错误信息。
5. 所有外部请求、图片下载、base64 解码、代理和超时控制由 Go Bridge 处理。

## 本地数据与文件

MVP 可先使用本地 JSON/浏览器存储，后续再升级 SQLite。跨平台 AppData 目录由 Go Bridge 统一管理：Windows 使用 `%AppData%/ShadowImage`，macOS 使用 `~/Library/Application Support/ShadowImage`。

```text
local app data
├── settings.json        AI Provider 配置（API Key 后续加密）
├── prompt-presets.json  平台 Prompt 模板与优化规则
├── projects.json        本地项目/SKU 信息
├── history.json         生成历史
├── uploads/             用户上传原图副本
└── outputs/             生成结果和导出图片
```

## 安全边界

```text
桌面端本地工具                         第三方/中转站 API
──────────────                        ───────────────
✅ 用户自行填写 API Key                ✅ 按用户配置接收请求
✅ API Key 仅本地保存                  ✅ 负责模型调用与计费
✅ 不上传到项目自有云端                ⚠️ 用户需信任该服务商
✅ 本地文件和历史记录                  ⚠️ 图片/Prompt 会发送给该服务商
```

MVP 安全要求：

- 不提交任何真实 API Key。
- UI 中 API Key 脱敏展示。
- 调用前提示：图片和 Prompt 会发送到用户配置的服务商。
- 后续可接入 Windows Credential Manager / macOS Keychain 或本地加密。

## 关键技术决策

1. **桌面端优先** — 先验证电商图片生成体验。
2. **用户自带 AI Key** — 用户手动填写中转站/API 配置。
3. **Provider Adapter** — 用适配层兼容不同 OpenAI-compatible 或自定义中转站。
4. **Fabric.js** — 负责轻量编辑、后期文字/图层合成和详情长图预览。
5. **Go Bridge 外部请求** — AI API 调用、图片下载、base64 解码、代理/超时由 Go 层统一处理。
6. **Go Image Composer 兜底** — 超长详情图最终导出预留 Go 后端稳定拼接能力。
7. **本地历史** — 生成记录和输出文件保存在本地。
8. **电商平台规则本地化** — 平台尺寸、图片类型、Prompt 预设在本地维护，保证工具开箱可用。
9. **提示词优化前置** — 生图前先把用户粗略描述优化为平台化、结构化、商品保持优先的 Prompt。

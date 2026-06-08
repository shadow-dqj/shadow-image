# 编码规范

## MVP 开发重点

当前 MVP 优先开发桌面端电商图片生成工具：设置 AI Provider、上传商品参考图、编辑 Prompt、调用用户配置的 AI 中转站、预览结果、本地保存与导出。

## Vue/TypeScript 规范

### 目录结构

```text
desktop/frontend/src/
├── api/                    ← AI Provider / Gateway 请求封装
│   ├── providers/          ← OpenAICompatibleProvider、CustomGatewayProvider
│   └── client/             ← HTTP client、错误处理
├── components/             ← 可复用组件
│   ├── common/             ← 通用组件
│   └── business/           ← ImageUploader、PromptEditor、ResultPreview 等
├── composables/            ← 组合式函数
│   ├── useAiSettings.ts
│   ├── useImageUpload.ts
│   ├── usePromptOptimizer.ts
│   └── useGeneration.ts
├── constants/              ← 平台规则、默认 Prompt、尺寸预设
├── layouts/                ← 布局组件
├── router/                 ← 路由配置
├── stores/                 ← Pinia stores
│   ├── aiSettings.ts
│   ├── generation.ts
│   └── project.ts
├── types/                  ← TypeScript 类型定义
├── utils/                  ← 图片、文件、Prompt 工具
└── views/                  ← 页面组件
    ├── SettingsView.vue
    ├── GenerateView.vue
    ├── HistoryView.vue
    └── ExportView.vue
```

### 命名规范

- 组件文件：PascalCase（`ImageUploader.vue`）
- 页面组件：`*View.vue`（`GenerateView.vue`）
- 组合式函数：`use` 前缀驼峰（`useGeneration.ts`）
- Store：业务名（`aiSettings.ts`、`generation.ts`）
- 类型/接口：PascalCase（`AiProviderSettings`, `GenerateImageRequest`）
- 常量：UPPER_SNAKE 或具名对象（`PLATFORM_PRESETS`）

### 组件规范

```vue
<script setup lang="ts">
// 1. imports
// 2. props/emits
// 3. composables/stores
// 4. reactive state
// 5. computed
// 6. methods
// 7. lifecycle
</script>

<template>
  <!-- template -->
</template>

<style scoped>
/* scoped styles */
</style>
```

## AI Provider 代码规范

### 统一抽象

所有模型/中转站差异必须收敛到 Provider 层，不允许页面直接拼接不同厂商请求。

```ts
export interface ImageGenerationProvider {
  testConnection(settings: AiProviderSettings): Promise<void>
  generate(request: GenerateImageRequest): Promise<GenerateImageResult>
}
```

建议类型：

```ts
export interface AiProviderSettings {
  providerType: 'openai-compatible' | 'custom-gateway'
  baseUrl: string
  apiKey: string
  model: string
  timeoutSeconds: number
  defaultSize: string
  defaultQuality: string
}
```

### 错误处理

- 网络错误、鉴权错误、模型不支持、超时、响应格式错误必须转成用户可读消息。
- 不在错误提示中泄露完整 API Key。
- 日志中不要打印完整 Key 或图片 base64。

### 安全处理

- API Key 输入框默认 password 类型。
- 展示时只显示前后少量字符或完全隐藏。
- 本地保存前预留加密/Keychain 扩展点。

## 电商图片业务规范

### Prompt 原则

- Prompt 必须强调保持商品主体：形状、颜色、材质、Logo、包装文字、比例。
- 平台规则必须参与 Prompt 生成。
- 广告文字尽量通过 Fabric.js 后期叠加，不依赖模型直接生成文字。
- Negative Prompt 应包含：不改变商品、不添加多余文字、不改变 Logo、不扭曲包装。

### Prompt Optimizer 规范

提示词优化逻辑必须集中在 composable、store 或 utils 中，不要散落在页面模板中。

建议类型：

```ts
export interface PromptOptimizationInput {
  productName: string
  category?: string
  sellingPoints: string[]
  platform: string
  imageType: string
  style?: string
  userPrompt?: string
  forbiddenChanges: string[]
}

export interface PromptOptimizationResult {
  optimizedPrompt: string
  negativePrompt: string
  platformHints: string[]
  preserveRules: string[]
  suggestedSize?: string
  suggestedQuality?: string
}
```

要求：

- 优化结果必须可编辑。
- 不直接触发生图，必须由用户点击生成确认。
- 默认加入商品保持规则。
- 平台规则从统一常量读取。
- Negative Prompt 必须覆盖商品变形、文字错乱、Logo 改动、包装文字改动等风险。

### 平台预设

平台规则应集中维护在常量或配置文件中：

```text
Amazon       白底主图、1:1、无文字、无水印
Shopify      商品图/场景图、方图优先
TikTok/抖音  9:16 竖版广告、移动优先
小红书       3:4 或 4:5 封面
```

### 本地历史

每次生成应记录：

- 原图路径
- 输出图路径
- Provider 类型
- Base URL（可记录 host，不记录 Key）
- Model
- 用户原始 Prompt
- 优化后 Prompt / Negative Prompt
- 平台和图片类型
- 尺寸/质量
- 生成时间
- 错误信息（如果失败）

## Wails/Go Bridge 规范（后续）

Go 代码仅用于桌面本地能力：

- 文件选择/保存
- 本地配置读写
- 打开输出目录
- SQLite/Keychain（后续）
- 不承载云端业务逻辑

## Git 规范

```text
feat:     新功能
fix:      Bug 修复
docs:     文档变更
style:    代码格式
refactor: 重构
test:     测试
chore:    构建/工具变更
```

## 后续云端规范

当前不引入服务端数据库、积分事务和任务队列规范；如未来产品方向变化，再单独新增对应文档。

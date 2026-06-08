# AI Agent 作图业务流程

## 目标

把软件打磨成“电商作图 Agent”，让用户不是从空白 Prompt 开始，而是按电商出图流程一步步完成：理解商品、明确平台、优化提示词、生成图片、检查质量、局部调整、导出成品。

该 Agent 不是聊天机器人，而是内置在桌面工具里的作图流程编排器。桌面端页面流、状态机、本地目录、Provider 能力矩阵和 Composer 落地设计见：[桌面端主图 + 详情长图工程落地方案](../architecture/desktop-generation-architecture.md)。

## 核心原则

1. **商品主体优先**：任何风格变化都不能改变商品形状、颜色、材质、Logo、包装文字和比例。
2. **平台目标明确**：每次生成必须绑定平台和图片类型。
3. **先优化再生成**：用户粗略描述必须先经过 Prompt Optimizer，用户确认后再生成。
4. **先单张后批量**：先把单张图闭环做稳，再扩展批量 SKU。
5. **AI 生成 + 本地编辑结合**：背景、场景、光影交给模型；广告文字、Logo、尺寸、裁剪优先本地编辑。
6. **结果可复用**：每次生成都记录输入、优化提示词、参数和结果，方便复用、改写和批量化。

## Agent 作图流程总览

```text
1. 商品导入
   → 上传商品参考图
   → 填写商品名称/类目/卖点/禁忌项

2. 目标选择
   → 选择平台：Amazon / Shopify / TikTok / 抖音 / 小红书
   → 选择图片类型：白底主图 / 场景图 / 竖版广告 / 社媒封面
   → 选择风格：简洁 / 高级 / 自然光 / 年轻化 / 节日氛围

3. 提示词优化
   → 合并商品信息、平台规则、用户想法
   → 生成优化 Prompt
   → 生成 Negative Prompt
   → 给出尺寸/质量建议
   → 用户可编辑确认

4. 图片生成
   → 调用用户配置的 AI 中转站/API
   → 显示生成状态
   → 失败时给出原因和可操作建议

5. 结果审阅
   → 检查商品是否变形
   → 检查 Logo/包装文字是否被篡改
   → 检查平台比例/背景/文字空间
   → 标记可用/需重试/需编辑

6. 本地编辑
   → 裁剪/缩放/位置调整
   → 添加广告文字/Logo/贴纸
   → 调整画布尺寸

7. 导出归档
   → 按平台尺寸导出
   → 保存生成历史
   → 支持复制 Prompt 再生成
```

## 分步骤业务设计

### 1. 商品导入 Agent

目标：收集足够上下文，避免模型随意改商品。

输入：

| 字段 | 说明 |
|------|------|
| 商品参考图 | 必填，真实商品外观依据 |
| 商品名称 | 用于提示词语义约束 |
| 商品类目 | 决定场景和平台规则 |
| 核心卖点 | 影响构图与场景表达 |
| 保持项 | Logo、包装文字、颜色、材质、比例等 |
| 禁止项 | 不加人物、不改文字、不换颜色、不加无关道具等 |

输出：

- `ProductContext`
- 商品保持规则
- 默认禁止项

### 2. 平台目标 Agent

目标：把“我要一张好看的图”变成明确的电商图片任务。

平台预设：

| 平台 | 图片类型 | 业务目标 |
|------|---------|---------|
| Amazon | 白底主图 | 合规、清晰、突出商品 |
| Shopify | 商品图/场景图 | 品牌感、详情页转化 |
| TikTok / 抖音 | 竖版广告 | 移动端吸引力、留出文案空间 |
| 小红书 | 封面图 | 生活方式、种草感、封面吸引力 |

输出：

- 平台规则
- 推荐尺寸
- 默认构图
- Prompt 风格片段

### 3. Prompt Optimizer Agent

目标：生成可控、稳定、适合电商生图的 Prompt。

输入：

```text
ProductContext
PlatformTarget
UserIntent
StylePreference
ForbiddenChanges
```

输出：

```text
Optimized Prompt
Negative Prompt
Preserve Rules
Platform Hints
Suggested Params
```

优化模板结构：

```text
[任务目标]
Create an ecommerce product image for <platform>/<image type>.

[商品保持]
Strictly preserve the product's shape, color, material, logo, package text, proportions, and visible details.

[场景/构图]
Set the product in ... with ... lighting and ... composition.

[平台规则]
Follow <platform> requirements: size/aspect/background/text rules.

[后期编辑空间]
Leave clean space for editable marketing copy when needed.

[禁止项]
Do not change the product, do not alter logos or package text, do not generate unreadable text, do not add unrelated objects.
```

### 4. Generation Agent

目标：调用用户配置的模型接口，完成生图请求。

职责：

- 根据 Provider 类型拼接请求。
- 带上商品参考图。
- 使用优化后的 Prompt。
- 处理超时、鉴权失败、模型不支持、响应格式错误。
- 保存请求摘要，不保存完整敏感凭证。

### 5. Quality Review Agent

目标：帮助用户判断生成图是否能用于电商。

MVP 可先做半自动检查清单：

| 检查项 | 判断方式 |
|--------|---------|
| 商品主体是否保持 | 用户肉眼确认，后续可加图像对比 |
| Logo/包装文字是否异常 | 用户确认，后续可加 OCR/局部检测 |
| 图片比例是否符合平台 | 本地尺寸检查 |
| 是否留出文字空间 | 规则/人工确认 |
| 是否出现无关物体 | 人工确认，后续可加视觉模型 |
| 是否适合导出 | 用户选择通过/重试/编辑 |

结果状态：

```text
usable      可用
retry       需要重新生成
edit_needed 需要本地编辑
rejected    丢弃
```

### 6. Edit Agent

目标：把“差一点能用”的图变成可发布素材。

MVP 编辑能力：

- 裁剪
- 缩放
- 调整画布比例
- 添加文字
- 添加 Logo/贴纸
- 导出不同尺寸

注意：广告文字优先在编辑层添加，不建议直接让模型生成中文/英文营销文字。

### 7. Export Agent

目标：让生成结果按平台可直接使用。

导出内容：

- 图片文件
- 平台名
- 图片类型
- 尺寸/格式
- 使用的 Prompt / Negative Prompt
- 商品参考图路径
- 生成时间

## 一键生成主图 + 详情长图 Agent Workflow

当前开发调研阶段先固定产品大方向：用户上传**一张商品参考图**后，软件围绕该商品自动化生成平台主图和电商详情长图草案。后续开发、Prompt、编辑器和本地导出都应围绕这条主线展开，避免迭代偏离为泛化 AI 绘图工具。

```text
商品参考图 + 商品信息
→ 商品上下文 ProductContext
→ 自动生成任务 AutoGenerationJob
   ├── 主图任务 MainImageTask
   └── 详情长图任务 DetailLongImageTask
→ 统一视觉规范 VisualStyleGuide
→ 主图生成 / 质检 / 导出
→ 详情页大纲规划 / 分段生成 / 分段质检
→ 本地叠加文字、图标、参数表
→ 拼接导出详情长图
```

### 基准决策

1. **单商品优先**：MVP 只处理单个商品参考图，批量 SKU 后置。
2. **主图 + 详情长图是核心闭环**：不是只生成单张好看的图，而是生成可用于电商上架的一组素材。
3. **详情长图不一次性生成**：必须采用分段生成、统一风格、本地拼接。
4. **AI 负责视觉，本地负责文字和版式**：营销文案、图标、参数表、步骤编号和标注优先由本地编辑/模板层叠加。
5. **用户关键节点可确认**：MVP 可以先做到“一键生成草案 + 分段确认/重试”，不追求完全无人值守。
6. **商品主体不可变**：所有 Agent 必须继承商品保持规则，避免改变商品形状、颜色、材质、Logo、包装文字和比例。

### AutoGenerationJob

`AutoGenerationJob` 是一次自动作图任务的总编排对象，用于把主图任务和详情长图任务绑定在同一商品、同一平台、同一风格下。

```json
{
  "jobId": "local-generated-id",
  "productContext": {},
  "platformTarget": {},
  "stylePreference": "premium clean ecommerce style",
  "tasks": {
    "mainImage": {},
    "detailLongImage": {}
  },
  "status": "planning | generating | reviewing | composing | exported | failed"
}
```

### ProductContext

商品上下文是所有后续 Agent 的共同输入，目标是减少模型随意改商品。

```json
{
  "sourceImagePath": "local/path/product.png",
  "productName": "便携式榨汁杯",
  "category": "厨房小家电",
  "sellingPoints": ["便携", "无线", "易清洗"],
  "preserveRules": [
    "保持商品形状",
    "保持商品颜色",
    "保持材质质感",
    "保持 Logo 和包装文字",
    "保持商品比例和可见细节"
  ],
  "forbiddenRules": [
    "不改变商品结构",
    "不改变品牌标识",
    "不生成乱码文字",
    "不添加无关人物或道具"
  ]
}
```

### 主图 Agent

主图 Agent 作为 P0 最先落地能力，目标是快速生成可用于平台入口的商品图，并为详情长图提供视觉锚点。

流程：

```text
ProductContext
+ PlatformTarget
+ StylePreference
→ MainImagePrompt
→ AI image-to-image / edit 请求
→ 主图质检
→ MainVisualAnchor
→ 本地保存 / 导出
```

主图质检重点：

| 检查项 | 要求 |
|--------|------|
| 商品主体 | 不变形、不变色、不改变 Logo/包装文字 |
| 背景 | 符合平台要求，例如 Amazon 白底 |
| 构图 | 商品居中、比例合适、主体清晰 |
| 尺寸 | 符合平台推荐比例和分辨率 |
| 多余元素 | 不出现无关人物、道具、水印、乱码文字 |

主图生成后应提取或记录 `MainVisualAnchor`，供详情长图继承：

```json
{
  "dominantColors": ["#F7F3EA", "#D9B98F", "#222222"],
  "lighting": "soft diffused studio lighting",
  "backgroundStyle": "clean premium ecommerce background",
  "productPlacement": "centered hero product",
  "mood": "premium, clean, trustworthy"
}
```

### 详情长图 Agent

详情长图 Agent 是一个组合工作流，不是单次生图请求。它由规划、风格、分段 Prompt、分段生成、质检重试和本地拼接组成。

```text
ProductContext
+ PlatformTarget
+ MainVisualAnchor
→ DetailPagePlan Agent
→ VisualStyleGuide Agent
→ SectionPrompt Agent
→ SectionGeneration Agent
→ SectionQualityReview Agent
→ LocalComposer Agent
→ DetailLongImageExport
```

### 详情页大纲 DetailPagePlan

详情页大纲先规划内容结构，再进入生图。MVP 默认支持“快速版 4 段”和“完整版 8 段”。

- 快速版 4 段：首屏卖点、场景展示、核心卖点、参数/包装。
- 完整版 8 段：适合正式详情页草案，默认使用下表结构。

| 顺序 | 段落 | 目标 | AI 负责 | 本地编辑负责 |
|------|------|------|---------|-------------|
| 01 | 首屏卖点段 | 第一眼吸引用户，建立商品价值 | 商品大图、使用场景背景、氛围光影 | 核心卖点标题、副标题、卖点短句 |
| 02 | 场景展示段 | 展示商品在真实环境中的使用方式 | 商品在真实场景中、环境构图 | 场景说明文字、辅助标签 |
| 03 | 核心卖点段 1 | 表达卖点 A 的功能或利益点 | 局部特写、效果示意背景 | 卖点标题、图标、短文案 |
| 04 | 核心卖点段 2 | 表达卖点 B，可做对比或演示 | 对比背景、演示图、功能场景 | 对比文案、说明文字、箭头/标注 |
| 05 | 材质/细节段 | 展示商品局部细节、材质、工艺、质感 | 材质特写、微距质感背景 | 标注线、局部说明、材质说明 |
| 06 | 使用步骤段 | 用 1/2/3 步降低理解成本 | 步骤背景、示意构图 | 步骤编号、图标、短文案 |
| 07 | 参数规格段 | 展示尺寸、规格、颜色等理性信息 | 简洁背景、商品辅助图 | 本地文字表格、尺寸线、规格参数 |
| 08 | 包装/适用人群段 | 展示包装清单和适用人群 | 包装/配件视觉、人群氛围背景 | 包装清单文字、适用人群标签 |

大纲数据结构建议：

```json
{
  "mode": "quick4 | full8",
  "sections": [
    {
      "id": "hero",
      "order": 1,
      "title": "首屏卖点段",
      "goal": "第一眼吸引用户，建立商品价值",
      "visualType": "hero_scene",
      "targetHeight": 1200,
      "copySlots": ["主标题", "副标题", "核心卖点"]
    }
  ]
}
```

### 统一 VisualStyleGuide

为了保证详情长图风格一致，详情页生成前必须先生成一份全局视觉规范。每个详情段落的 Prompt 都必须引用同一份 Style Guide。

```json
{
  "colorPalette": {
    "primary": "#F7F3EA",
    "secondary": "#D9B98F",
    "accent": "#222222",
    "background": "#FFFFFF"
  },
  "backgroundStyle": "clean premium ecommerce background",
  "lighting": "soft diffused studio lighting",
  "composition": "product remains visually dominant, centered or rule-of-thirds",
  "typography": {
    "title": "bold sans-serif",
    "body": "clean readable sans-serif"
  },
  "iconStyle": "minimal line icons",
  "spacing": "large breathing space, consistent padding",
  "preserveRules": ["preserve product shape", "preserve product color", "preserve logo and package text"],
  "forbiddenRules": ["do not generate readable marketing text inside image", "do not alter product design"]
}
```

风格一致性约束：

- 所有分段共用同一张商品参考图。
- 所有分段共用同一份 `VisualStyleGuide`。
- 所有分段继承 `MainVisualAnchor` 的色彩、光影和背景方向。
- 每段预留文字区，避免模型直接生成营销文字。
- 只重试不合格段落，不整体重生成整张详情长图。

### 分段 Prompt 生成

每个详情段落的 Prompt 应由以下信息组合：

```text
ProductContext
+ PlatformTarget
+ VisualStyleGuide
+ Section Goal
+ Section Visual Requirement
+ Local Text Overlay Slots
+ Negative Prompt
```

段落 Prompt 必须强调：

- 使用商品参考图作为真实依据。
- 严格保持商品主体和包装细节。
- 遵循统一色板、光影、背景、构图规则。
- 为本地文字/图标/参数表留出干净空间。
- 不直接生成可读广告文字、水印、乱码、虚构 Logo。

### 分段生成、质检与重试

详情长图的每一段都是独立可重试单元。

```text
section.planned
→ section.prompt_ready
→ section.generating
→ section.reviewing
→ section.approved | section.retry_needed | section.edit_needed | section.rejected
```

分段质检重点：

| 检查项 | 要求 |
|--------|------|
| 商品一致性 | 商品形状、颜色、材质、Logo、包装文字不被篡改 |
| 风格一致性 | 色彩、光影、背景、构图符合统一 Style Guide |
| 段落目标 | 当前段落能表达对应卖点或信息目标 |
| 文字空间 | 留出本地叠加文案、图标、参数表的空间 |
| 平台适配 | 宽度、比例、信息密度适合目标平台详情页 |

重试规则：

- 单段失败只重试该段。
- 重试时复用同一 `ProductContext`、`VisualStyleGuide` 和段落目标。
- 用户可以选择“保持构图重试”或“换构图重试”。
- 连续失败时提示用户降低复杂度，例如减少道具、减少局部特写要求或切换为本地文字表达。

### 本地拼接与编辑边界

长图成品由本地 Composer 拼接，不由模型直接生成完整长图。

本地 Composer 负责：

- 将各段裁切/缩放到统一详情页宽度。
- 按段落顺序拼接成长图。
- 添加标题、副标题、卖点文案、步骤编号。
- 添加图标、参数表、尺寸线、标注线、包装清单。
- 控制段间距、背景衔接、留白节奏。
- 导出完整长图和分段素材。

AI 不负责：

- 直接生成长图内的营销文字。
- 生成参数表、价格、认证标识、平台 Logo。
- 生成需要精确可读的中文/英文文案。
- 一次性输出完整详情长图。

### 详情长图生成状态

```text
planning       详情大纲规划中
generating     分段生成中
reviewing      分段质检中
composing      长图拼接中
editable       可编辑
exported       已导出
failed         失败
```

### 详情长图导出内容

```text
detail-long-image.png        拼接后的长图
detail-sections/             分段图片
source-product-image          商品参考图
style-guide.json              统一视觉规范
section-plan.json             详情页大纲
section-prompts.json          每段 Prompt / Negative Prompt
text-overlays.json            本地叠加文案、图标、参数表配置
export-summary.json           平台、尺寸、导出时间
```

## MVP 页面建议

```text
SettingsView        AI Provider 设置
GenerateView        主作图流程页面
├── ProductPanel    商品图和商品信息
├── TargetPanel     平台/图片类型/风格
├── PromptPanel     提示词优化和编辑
├── GeneratePanel   生成按钮和状态
├── ReviewPanel     结果审阅
└── ExportPanel     保存/导出
HistoryView         历史记录和复用
```

## 优先落地顺序

1. ProductPanel：上传图 + 商品信息。
2. TargetPanel：平台/图片类型/风格选择。
3. PromptOptimizer：本地规则版提示词优化。
4. GeneratePanel：调用用户配置 API。
5. ResultPreview：展示结果。
6. ReviewPanel：人工质检清单。
7. History：保存可复用记录。
8. Export：按平台尺寸导出。

## 后续优化方向

- 根据历史成功图反推 Prompt 模板。
- 增加“同款再生成”“换背景”“换平台尺寸”。
- 增加商品主体一致性评分。
- 增加 OCR 检查包装文字是否被改。
- 增加批量 SKU 作图流程。

# AI Agent 作图业务流程

## 目标

把软件打磨成“电商作图 Agent”，让用户不是从空白 Prompt 开始，而是按电商出图流程一步步完成：理解商品、明确平台、优化提示词、生成图片、检查质量、局部调整、导出成品。

该 Agent 不是聊天机器人，而是内置在桌面工具里的作图流程编排器。

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

# 自动化书写功能实现文档流程

## 目的

本文定义 Claude 在自动开发功能时，如何同步书写和维护功能实现文档，确保后续 Agent 可以从文档继续理解、实现、测试和审查。

## 核心原则

1. **先文档后代码**：功能开发前先明确需求、边界和验收标准。
2. **文档跟随实现**：实现过程中同步更新任务、接口、本地数据和测试说明。
3. **可验证**：每个功能文档必须写清楚如何验证。
4. **可交接**：任何 Agent 读取文档后能继续开发。
5. **不写真实密钥**：配置只写变量名和占位符。

## 文档位置

推荐为每个复杂功能建立一个功能目录：

```text
docs/features/<feature-name>/
├── README.md          ← 功能概览
├── requirements.md    ← 需求说明
├── design.md          ← 技术设计
├── tasks.md           ← 实现任务清单
├── api.md             ← API 设计（如有）
├── database.md        ← 数据库变更（如有）
├── test-plan.md       ← 测试计划
└── review.md          ← 审查记录
```

简单功能可以只维护：

```text
docs/features/<feature-name>.md
```

## 自动化书写流程

```text
需求输入
  ↓
生成 requirements.md
  ↓
生成 design.md
  ↓
拆分 tasks.md
  ↓
实现代码 / migration / UI
  ↓
同步 api.md / database.md
  ↓
生成 test-plan.md
  ↓
执行验证
  ↓
生成 review.md
  ↓
归档或更新 README 索引
```

## 阶段 1：需求文档 requirements.md

### 输入

- 用户自然语言需求
- PRD 中相关条目
- 平台规则或业务约束

### 必须包含

```markdown
# <功能名> 需求说明

## 背景

## 用户目标

## 功能范围

### 包含

### 不包含

## 用户流程

## 业务规则

## 验收标准

## 风险与边界
```

### 示例验收标准

```markdown
## 验收标准

- 用户可以上传 jpg/png/webp 商品图。
- 文件超过限制时返回明确错误。
- 上传成功后生成本地素材记录。
- 桌面端可以使用用户手动配置的 AI Provider。
- 图片二进制不写入数据库，MVP 优先保存在本地输出目录。
```

## 阶段 2：技术设计 design.md

### 必须包含

```markdown
# <功能名> 技术设计

## 相关文档

## 架构位置

## 数据流

## 模块拆分

## 接口设计

## 数据库设计

## 错误处理

## 安全约束

## 可观测性
```

### 数据流示例

```text
Desktop Upload UI
  → Local file validation
  → Local preview
  → User-configured AI Provider
  → Local output/history
```

## 阶段 3：任务拆分 tasks.md

### 模板

```markdown
# <功能名> 任务清单

## 准备

- [ ] 阅读 PRD 和桌面端架构文档
- [ ] 确认本地数据/配置变更
- [ ] 确认可执行验证命令

## 桌面端

- [ ] 定义 TypeScript 类型
- [ ] 创建/更新 Pinia store
- [ ] 实现页面/组件
- [ ] 实现 AI Provider adapter
- [ ] 实现本地保存/读取
- [ ] 接入错误提示和 loading 状态

## 测试

- [ ] Provider 请求构造测试
- [ ] Store 单元测试
- [ ] 前端组件测试
- [ ] 手动端到端流程验证

## 验证

- [ ] type-check / lint / test / build
- [ ] code-review
- [ ] security-review
```

## 阶段 4：实现过程中同步文档

实现代码时需要同步记录：

| 变更类型 | 同步文档 |
|----------|----------|
| 新增 API | `api.md` |
| 新增/修改表 | `database.md` |
| 新增业务规则 | `requirements.md` 或 `design.md` |
| 新增错误码 | `api.md` |
| 新增测试 | `test-plan.md` |
| 审查发现 | `review.md` |

## 阶段 5：验证文档 test-plan.md

### 模板

````markdown
# <功能名> 测试计划

## 单元测试

| 模块 | 用例 | 预期 |
|------|------|------|

## 集成测试

| 流程 | 输入 | 预期 |
|------|------|------|

## 手动验证

1. 操作步骤
2. 预期结果
3. 异常场景

## 自动验证命令

```bash
# 前端 MVP
cd desktop/frontend
npm run type-check
npm run lint
npm run test
npm run build
```

## 跳过项

- 当前尚未 scaffold 的测试需要标记 SKIPPED，并说明原因。
````

## 阶段 6：审查记录 review.md

### 模板

```markdown
# <功能名> 审查记录

## 审查时间

## 审查范围

## 审查结果

| 严重度 | 文件 | 问题 | 处理状态 |
|--------|------|------|----------|

## 已修复

## 待处理

## 验证结果
```

## 阶段 7：归档

功能完成后：

1. 更新功能目录 `README.md`。
2. 更新 `docs/product/README.md` 或 `docs/architecture/README.md` 索引。
3. 如有架构决策，补充 `docs/decisions/NNNN-xxx.md`。
4. 如有新命令，更新 `CLAUDE.md` Common commands。
5. 如有新 skill/workflow，更新对应 README。

## 自动生成提示词模板

### 从需求生成文档

```text
请根据以下需求，在 docs/features/<feature-name>/ 下生成 requirements.md、design.md、tasks.md、test-plan.md。
要求：遵循项目 CLAUDE.md、PRD 和架构文档，不写真实密钥，当前缺少脚手架的验证项标记 SKIPPED。
```

### 从实现更新文档

```text
请读取本次修改的代码和 docs/features/<feature-name>/，更新 api.md、database.md、test-plan.md 和 review.md，确保文档与实现一致。
```

### 从审查结果修复文档

```text
请根据审查报告修复功能文档中的错误、死链、过期描述，并更新 review.md 的处理状态。
```

## 当前项目建议

本项目后续建议优先为这些功能建立文档目录：

```text
docs/features/ai-settings/
docs/features/upload-preview/
docs/features/prompt-presets/
docs/features/prompt-optimizer/
docs/features/generation/
docs/features/history/
docs/features/export/
docs/features/canvas-editor/
```

其中 `ai-settings`、`prompt-optimizer` 和 `generation` 涉及用户填写的访问凭证、提示词优化和外部 API 调用，必须包含安全边界、错误处理和手动验证步骤。

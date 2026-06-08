# tdd-cycle

## 描述

TDD 开发循环：先写测试 → 测试失败 → 写实现 → 测试通过 → 重构验证。当前 MVP 主要适用于桌面端 AI 作图中的纯逻辑、状态机、适配器和工具函数。

## 阶段

1. **Red** — 根据需求生成测试（应失败）。
2. **Green** — 生成最小实现让测试通过。
3. **Refactor** — 重构优化，保持测试通过。
4. **Verify** — 最终验证。

## Agent 编排

### Phase 1: Red (Test First)

- Agent: 根据功能需求描述，生成测试文件。
- 运行测试，确认 FAIL（Red）。
- 如果测试一开始就 PASS，说明测试没有覆盖新需求，需要重写测试。

### Phase 2: Green (Minimal Implementation)

- Agent: 生成最小代码让测试通过。
- 运行测试，确认 PASS（Green）。
- 不在 Green 阶段引入超出需求的大型抽象。

### Phase 3: Refactor

- Agent: 审查代码，优化结构、性能、可读性和边界命名。
- 运行测试，确认仍 PASS。

### Phase 4: Verify

- Agent 1: 编译/type-check 检查。
- Agent 2: 测试运行。
- Agent 3: 代码审查。
- Agent 4: 架构约束检查。

## 适用场景

适合：

- ✅ PromptBuilder 规则函数。
- ✅ PlatformRules 尺寸/平台约束。
- ✅ ProviderCapabilities 能力矩阵和降级策略。
- ✅ Provider response url/base64 解析。
- ✅ 错误归一化函数。
- ✅ DetailPagePlan quick4/full8 模板生成。
- ✅ VisualStyleGuide 默认值/合并规则。
- ✅ SectionStatus / JobStatus 状态机。
- ✅ ComposerConfig / TextOverlay 数据转换。
- ✅ 跨平台路径工具的纯逻辑包装。
- ✅ History JSON schema 读写前的数据校验。

不适合：

- ❌ 纯 UI 布局组件。
- ❌ 视觉样式微调。
- ❌ 配置/常量文件本身。
- ❌ 需要真实 AI Gateway 的端到端生成。
- ❌ Windows/macOS 打包签名流程。

## 测试边界要求

1. Provider 测试必须使用 mock，不调用真实用户 API。
2. API Key 只能使用假值，不能写入快照或日志。
3. 路径测试不能写死真实用户目录，应 mock Go Bridge 返回值。
4. 详情长图测试应覆盖单段失败、单段重试和已生成段落不重复请求。
5. Composer 测试应区分 Canvas 预览配置和 Go Image Composer 导出配置。

## 使用方式

```text
@claude TDD 实现 PromptBuilder 主图提示词规则，使用 tdd-cycle
@claude TDD 实现 ProviderCapabilities 降级判断，使用 tdd-cycle
@claude TDD 实现 DetailSectionTask 状态机，使用 tdd-cycle
@claude TDD 实现 quick4 详情页大纲模板，使用 tdd-cycle
@claude TDD 实现 response base64/url 解析，使用 tdd-cycle
```

## 输出示例

```text
🔴 RED:    DetailSectionStatus retry transition FAILED (4 tests, 0 passed)
🟢 GREEN:  DetailSectionStatus retry transition PASSED (4 tests, 4 passed)
🔵 REFACTOR: DetailSectionStatus retry transition PASSED (4 tests, 4 passed)
✅ VERIFY: TypeCheck ✅, Test ✅, PolicyCheck ✅
```

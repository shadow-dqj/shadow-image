# comprehensive-review

## 描述

使用多 Agent 对代码进行并行多维度审查。当前 MVP 审查重点是桌面端主图 + 详情长图业务一致性、Go Bridge 安全边界、跨平台路径、Provider Adapter、分段状态机和导出兜底。

## 阶段

1. **Find** — 并行发现各维度问题。
2. **Verify** — 对发现的问题进行验证，过滤误报。
3. **Report** — 合成审查报告。

## Agent 编排

### Phase 1: Find (parallel)

- Agent 1: 正确性检查
  - 任务状态机是否正确。
  - 主图/详情分段生成流程是否可恢复。
  - 单段失败是否只重试当前段。
  - 已生成段落是否避免重复请求。
  - Provider response url/base64 解析是否正确。

- Agent 2: 安全性检查
  - API Key 是否脱敏。
  - API Key 是否避免进入 `job.json`、`history.json`、错误摘要、导出包和测试快照。
  - 前端 WebView 是否避免直接请求用户配置的 AI Gateway。
  - Go Bridge Provider Adapter 是否统一处理外部请求。
  - 调用第三方/中转站前是否有数据发送提示。

- Agent 3: 跨平台检查
  - 是否写死 Windows/macOS 绝对路径。
  - AppData、项目目录、任务目录是否由 Go Bridge 管理。
  - 打开文件夹、预览 URL、导出路径是否跨平台。
  - Windows WebView2 / macOS WebView 差异是否被考虑。
  - Windows Credential Manager / macOS Keychain 后续边界是否未被破坏。

- Agent 4: 业务一致性检查
  - 是否仍围绕单商品主图 + 详情长图闭环。
  - 是否误引入泛 AI 绘图、云端后台、积分、订阅、服务端队列或服务端数据库。
  - 详情长图是否采用 quick4/full8、VisualStyleGuide、分段 Prompt、本地拼接。
  - 广告文字、参数表、图标、标注是否优先本地叠加。

- Agent 5: 性能与可靠性检查
  - 长图导出是否只依赖 Canvas，是否预留 Go Image Composer 兜底。
  - 大图/多段图片是否存在明显内存风险。
  - API 请求是否有超时、代理、错误归一化和用户可读提示。
  - 本地 JSON 写入是否考虑中断恢复和原子性。

- Agent 6: 可维护性/简化检查
  - Provider 差异是否集中在 Adapter 中。
  - 页面组件是否混入过多业务逻辑。
  - types/store/bridge/component 命名是否一致。
  - 是否有重复 Prompt 拼接逻辑。
  - 是否过度设计超出当前 MVP-A/B/C 阶段。

### Phase 2: Verify (pipeline)

- 每个发现用一个 Agent 验证是否为真实问题。
- 验证时必须引用具体文件和代码行。
- 对无法复现或证据不足的问题标记为“未确认”，不要作为必须修复项。

### Phase 3: Report

综合所有验证结果，生成审查报告。

## 审查清单

### 必须修复

- API Key 明文进入任务、历史、日志、错误摘要或导出包。
- 前端直接请求用户配置的 AI Gateway。
- 本地路径写死到 Windows 或 macOS 单一平台。
- 详情长图一次性生成完整长图，没有分段状态和重试。
- 生成失败后需要整体重来，无法单段重试。
- 引入云端后台、服务端队列、积分/订阅等非当前范围。

### 应该修复

- Provider 错误没有统一成用户可读错误。
- response url/base64 解析散落在 UI 组件中。
- Canvas 导出没有超长图风险提示或 Go Composer 兜底设计。
- PromptBuilder 和平台规则无法测试。
- `VisualStyleGuide` 没有被详情分段复用。
- 任务状态未落盘，应用关闭后无法恢复。

### 可以后续优化

- SQLite 替代 JSON。
- Windows Credential Manager / macOS Keychain 正式接入。
- OCR 检查包装文字。
- 商品主体一致性评分。
- AI Planner 自动生成详情大纲。
- macOS Universal 包和签名/Notarization 自动化。

## 使用方式

```text
@claude review 最近修改的文件，使用 comprehensive-review
@claude 全面审查这次 PR 的变更
@claude 审查 MainImageTask 和 Provider Adapter 是否符合桌面 MVP 边界
@claude 审查 DetailComposer 是否满足跨平台导出要求
```

## 输出

审查报告包含：

- 严重问题（必须修复）。
- 建议改进（应该修复）。
- 提示（可以后续优化）。
- 已验证通过的关键约束。
- 未覆盖或跳过的检查项。

# dev-verify-loop

## 描述

开发 → 编译 → 测试 → 修复 → 验证 的完整闭环工作流。当前 MVP 用于桌面端 Vue/TypeScript + Wails/Go Bridge 功能开发后确保代码可编译、测试通过，并符合主图 + 详情长图工程边界。

## 阶段

1. **Detect** — 探测本次变更涉及前端、Go Bridge、文档还是混合模块。
2. **Build** — 前端类型检查/构建检查，必要时 Go/Wails 构建检查。
3. **Fix** — 如有错误，自动修复。
4. **Test** — 运行测试。
5. **Retry** — 失败则修复重试。
6. **PolicyCheck** — 检查桌面 MVP 架构约束。
7. **Report** — 输出验证报告。

## Agent 编排

### Phase 1: Detect

- Agent: 先执行脚手架探测。
- 优先检查 `desktop/frontend/package.json`。
- 如修改 Go Bridge/Wails 文件，检查 Go module/Wails 结构。
- 对不存在的脚手架只记录 `SKIPPED: scaffold missing`，不要进入 auto-fix。

### Phase 2: Build

前端：

- 运行 `npm run type-check`。
- 运行 `npm run lint`。
- 运行 `npm run build`。

Go/Wails（如相关文件存在或本次修改涉及）：

- 运行 Go 单元测试或编译检查。
- 如项目提供 Wails 构建命令，运行最小构建验证。

### Phase 3: Fix

- 如有类型、lint、构建错误，逐个使用 auto-fix Agent 修复。
- 每修复一个错误重新验证。
- 最多 3 轮。

### Phase 4: Test

- 运行已定义的前端测试命令：`npm run test` 或 `npm test`。
- 如涉及 Go Bridge，运行对应 Go 测试。
- 如果没有测试脚本，记录为 WARN，不视为失败。

### Phase 5: TestFix

- 如有测试失败，逐个修复。
- 每修复一个重新运行测试。
- 最多 3 轮。

### Phase 6: PolicyCheck

检查是否符合当前桌面 MVP 约束：

- 前端是否避免直接请求用户配置的 AI Gateway。
- AI Provider 是否走 Go Bridge Provider Adapter。
- API Key 是否避免进入日志、历史、任务文件、测试快照。
- 本地路径是否由 Go Bridge 管理，未写死 Windows/macOS 绝对路径。
- 详情长图是否分段生成，支持单段重试。
- Canvas/Fabric.js 是否主要用于预览/轻量编辑，超长图导出是否预留 Go Image Composer。
- 是否仍未引入云端后台、服务端队列、服务端数据库、积分/订阅逻辑。

### Phase 7: Report

汇总 Build + Test + PolicyCheck 结果，并说明是否符合桌面端主图 + 详情长图 MVP 方向。

## 使用方式

```text
# 对最近修改的桌面端代码运行验证闭环
@claude verify 最近的改动，使用 dev-verify-loop

# 对特定模块运行
@claude verify desktop/frontend/src/views/GenerateWorkspaceView.vue 使用 dev-verify-loop

# 对 Go Bridge Provider Adapter 运行
@claude verify Go Bridge Provider Adapter，使用 dev-verify-loop
```

## 退出条件

- ✅ type-check + lint + test + build + policy check 全部通过 → 输出 PASS 报告。
- ❌ 3 轮修复仍未通过 → 输出 FAIL 报告 + 未修复项清单。
- ⚠️ 无测试文件 → 构建通过即可，提示缺少测试覆盖。
- ⚠️ 脚手架缺失 → 记录 SKIPPED，不伪造验证结果。

## 输出示例

```text
🟢 TypeCheck: PASS
🟢 Lint: PASS
🟢 Test: PASS (18 passed)
🟢 Build: PASS
🟢 PolicyCheck: PASS
📊 MVP Fit: 主图 + 详情长图桌面流程保持清晰边界，AI 请求经 Go Bridge，路径跨平台。
```

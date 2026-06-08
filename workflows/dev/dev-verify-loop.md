# dev-verify-loop

## 描述

开发 → 编译 → 测试 → 修复 → 验证 的完整闭环工作流。当前 MVP 主要用于桌面端 Vue/TypeScript 功能开发后确保代码可编译、测试通过。

## 阶段

1. **Build** — 前端类型检查/构建检查
2. **Fix** — 如有错误，自动修复
3. **Test** — 运行测试
4. **Retry** — 失败则修复重试
5. **Report** — 输出验证报告

## Agent 编排

### Phase 1: Build
- Agent: 先执行脚手架探测：优先检查 `desktop/frontend/package.json`
- 运行前端 type-check/lint/build
- 历史 Go server 仅在相关文件修改时检查
- 对不存在的脚手架只记录 `SKIPPED: scaffold missing`，不要进入 auto-fix

### Phase 2: Fix (pipeline)
- 如有类型、lint、构建错误，逐个使用 auto-fix Agent 修复
- 每修复一个错误重新验证
- 最多 3 轮

### Phase 3: Test
- Agent: 运行已定义的前端测试命令：`npm run test` 或 `npm test`
- 如果没有测试脚本，记录为 WARN，不视为失败

### Phase 4: TestFix (pipeline)
- 如有测试失败，逐个修复
- 每修复一个重新运行测试
- 最多 3 轮

### Phase 5: Report
- Agent: 汇总 Build + Test 结果，并说明是否符合桌面 AI 生图 MVP 方向

## 使用方式

```text
# 对最近修改的桌面端代码运行验证闭环
@claude verify 最近的改动，使用 dev-verify-loop

# 对特定模块运行
@claude verify desktop/frontend/src/views/GenerateView.vue 使用 dev-verify-loop
```

## 退出条件

- ✅ type-check + lint + test + build 全部通过 → 输出 PASS 报告
- ❌ 3 轮修复仍未通过 → 输出 FAIL 报告 + 未修复项清单
- ⚠️ 无测试文件 → 构建通过即可，提示缺少测试覆盖

## 输出示例

```text
🟢 TypeCheck: PASS
🟢 Lint: PASS
🟢 Test: PASS (18 passed)
🟢 Build: PASS
📊 MVP Fit: AI Provider 设置与商品图生成流程保持清晰边界
```

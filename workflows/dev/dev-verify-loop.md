# dev-verify-loop

## 描述

开发→编译→测试→修复→验证 的完整闭环工作流。适用于新功能开发后自动确保代码可编译、测试通过。

## 阶段

1. **Build** — 编译检查
2. **Fix** — 如有错误，自动修复
3. **Test** — 运行测试
4. **Retry** — 失败则修复重试
5. **Report** — 输出验证报告

## Agent 编排

### Phase 1: Build
- Agent: 先执行脚手架探测：Go 验证仅在 `go.mod` 存在时运行；Vue 验证仅在 `package.json` 存在时运行
- 对存在的脚手架运行对应 build/typecheck/vet
- 对不存在的脚手架只记录 `SKIPPED: scaffold missing`，不要进入 auto-fix

### Phase 2: Fix (pipeline)
- 如有编译错误，逐个使用 auto-fix Agent 修复
- 每修复一个错误重新编译
- 最多 3 轮

### Phase 3: Test
- Agent: 只运行已定义的测试命令：Go 项目运行 `go test ./...`；前端项目优先运行 `npm test` 或 `npm run test`
- 如果没有测试脚手架或脚本，记录为 WARN，不视为失败

### Phase 4: TestFix (pipeline)
- 如有测试失败，逐个修复
- 每修复一个重新运行测试
- 最多 3 轮

### Phase 5: Report
- Agent: 汇总 Build + Test 结果

## 使用方式

```text
# 对最近修改的代码运行验证闭环
@claude verify 最近的改动，使用 dev-verify-loop

# 对特定模块运行
@claude verify server/internal/handler/ 使用 dev-verify-loop
```

## 退出条件

- ✅ 编译通过 + 测试全部通过 → 输出 PASS 报告
- ❌ 3 轮修复仍未通过 → 输出 FAIL 报告 + 未修复项清单
- ⚠️ 无测试文件 → 编译通过即可，提示缺少测试覆盖

## 输出示例

```text
🟢 Build: PASS (go build ✅, go vet ✅, vue-tsc ✅)
🟡 Test: WARN (12/15 passed, 3 skipped, 0 failed)
📊 Coverage: service 68%, handler 45%
⚠️  Missing tests: UserHandler.Delete, ProjectService.Update
```

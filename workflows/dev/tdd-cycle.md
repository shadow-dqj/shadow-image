# tdd-cycle

## 描述

TDD 开发循环：先写测试 → 测试失败 → 写实现 → 测试通过 → 重构验证。

## 阶段

1. **Red** — 根据需求生成测试（应失败）
2. **Green** — 生成最小实现让测试通过
3. **Refactor** — 重构优化，保持测试通过
4. **Verify** — 最终验证

## Agent 编排

### Phase 1: Red (Test First)
- Agent: 根据功能需求描述，生成测试文件
- 运行测试，确认 FAIL（Red）

### Phase 2: Green (Minimal Implementation)
- Agent: 生成最小代码让测试通过
- 运行测试，确认 PASS（Green）

### Phase 3: Refactor
- Agent: 审查代码，优化结构/性能/可读性
- 运行测试，确认仍 PASS

### Phase 4: Verify
- Agent 1: 编译检查
- Agent 2: 测试运行
- Agent 3: 代码审查

## 使用方式

```text
@claude TDD 实现 <功能描述>，使用 tdd-cycle
@claude 用 TDD 方式实现积分扣减函数
```

## 适用场景

- ✅ 纯函数 / 业务逻辑（积分计算、校验规则）
- ✅ Repository 层（CRUD + 边界条件）
- ✅ Service 层（有 mock 依赖）
- ❌ UI 布局组件（适合截图对比测试）
- ❌ 配置/常量定义

## 输出示例

```text
🔴 RED:    TestCreditService_Deduct FAILED (3 tests, 0 passed)
🟢 GREEN:  TestCreditService_Deduct PASSED (3 tests, 3 passed)
🔵 REFACTOR: TestCreditService_Deduct PASSED (3 tests, 3 passed)
✅ VERIFY: Build ✅, Vet ✅, Test ✅
```

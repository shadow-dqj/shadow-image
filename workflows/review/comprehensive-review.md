# comprehensive-review

## 描述

使用多 Agent 对代码进行并行多维度审查。

## 阶段

1. **Find** — 并行发现各维度问题
2. **Verify** — 对发现的问题进行验证
3. **Report** — 合成审查报告

## Agent 编排

### Phase 1: Find (parallel)
- Agent 1: 正确性检查（逻辑错误、边界条件）
- Agent 2: 安全性检查（注入、权限、密钥）
- Agent 3: 性能检查（N+1、缓存、并发）
- Agent 4: 规范检查（命名、分层、错误处理）
- Agent 5: 简化检查（重复代码、过度设计）

### Phase 2: Verify (pipeline)
- 每个发现用一个 Agent 验证是否为真实问题

### Phase 3: Report
- Agent: 综合所有验证结果，生成审查报告

## 使用方式

```text
@claude review 最近修改的文件，使用 comprehensive-review
@claude 全面审查这次 PR 的变更
```

## 输出

审查报告包含：
- 严重问题（必须修复）
- 建议改进（应该修复）
- 提示（可以忽略）

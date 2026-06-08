# build-verify

## 描述

对项目进行编译检查和代码质量验证，收集所有错误和警告。

## 触发条件

- "编译检查 / build / 构建"
- "验证代码能不能编译 / verify build"
- "检查有没有错误 / check errors"
- 代码生成后需要验证

## 上下文依赖

- `go.mod` / `go.sum` — Go 依赖
- `package.json` — 前端依赖
- `docs/development/coding-standards.md` — 编码规范

## 验证前置检查

当前仓库可能仍处于规划阶段。执行验证前必须先检查对应脚手架是否存在：

| 范围 | 必须存在 | 可执行验证 |
|------|---------|-----------|
| Go 后端 | `server/go.mod` 或根目录 `go.mod` | Go build/test/vet |
| Vue 前端 | `desktop/frontend/package.json` 或根目录 `package.json` | Type check/lint/build |
| MySQL 迁移 | `server/migrations/*.sql` | SQL 语法/规则审查；只有用户确认目标库后才执行 |

如果脚手架不存在，只报告“当前无法运行该类验证”，不要把缺失脚手架当成编译错误，也不要进入 auto-fix。

## 验证步骤

### Go 后端

```bash
# 1. 编译检查
go build ./...

# 2. 静态分析
go vet ./...

# 3. 代码格式检查
gofmt -l .

# 4. 依赖检查（只读）
go mod verify

# 如需整理依赖，单独报告并等待用户确认后再运行 go mod tidy
```

### Vue 前端

```bash
# 1. 类型检查
npx vue-tsc --noEmit

# 2. Lint 检查
npx eslint src/ --ext .ts,.vue

# 3. 构建验证
npm run build
```

### MySQL 迁移

```bash
# 语法检查：通过 MCP 在临时库执行迁移
# 检查索引、外键、约束是否合理
```

## 输出

```text
✅ build: PASS
✅ vet: PASS
✅ format: PASS
---
❌ server/internal/handler/user.go:23: undefined: UserService
❌ server/internal/handler/user.go:45: cannot use req (type CreateUserReq) as type *CreateUserReq
---
Summary: 2 errors, 0 warnings
```

## 错误分类

| 类别 | 示例 | 严重度 |
|------|------|--------|
| compile_error | undefined, type mismatch | 🔴 必须修复 |
| vet_warning | unreachable code, shadowed var | 🟡 应该修复 |
| format_issue | gofmt mismatch | 🟢 自动格式化 |
| dep_error | missing dependency | 🔴 必须修复 |

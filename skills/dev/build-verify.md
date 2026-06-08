# build-verify

## 描述

对桌面端项目进行编译检查和代码质量验证，收集所有错误和警告。

## 当前重点

当前 MVP 只验证 `desktop/frontend` 桌面前端。验证目标是确保 Vue/TypeScript 代码、AI Provider 适配、本地配置、上传/生成/导出相关代码可构建、可测试。

## 触发条件

- "编译检查 / build / 构建"
- "验证代码能不能编译 / verify build"
- "检查有没有错误 / check errors"
- 代码生成后需要验证

## 上下文依赖

- `desktop/frontend/package.json` — 前端依赖和 scripts
- `docs/development/coding-standards.md` — 编码规范
- `CLAUDE.md` — 当前 MVP 方向

## 验证前置检查

| 范围 | 必须存在 | 可执行验证 |
|------|---------|-----------|
| Vue 前端 | `desktop/frontend/package.json` | type-check/lint/test/build |
| Wails Bridge | `desktop/go.mod`（如后续存在） | 桌面桥接检查 |

如果脚手架不存在，只报告“当前无法运行该类验证”，不要把缺失脚手架当成编译错误，也不要进入 auto-fix。

## 验证步骤

### Vue 前端

```bash
cd desktop/frontend
npm run type-check --if-present
npm run lint --if-present
npm run test --if-present
npm run build --if-present
```

## 输出

```text
✅ desktop/frontend type-check: PASS
✅ desktop/frontend lint: PASS
✅ desktop/frontend test: PASS
✅ desktop/frontend build: PASS
---
Summary: 0 errors, 0 warnings
```

## 错误分类

| 类别 | 示例 | 严重度 |
|------|------|--------|
| type_error | TypeScript 类型不匹配 | 🔴 必须修复 |
| lint_error | ESLint 失败 | 🟡 应该修复 |
| test_failure | Vitest 用例失败 | 🔴 必须修复 |
| build_error | Vite build 失败 | 🔴 必须修复 |
| security_warning | 日志泄露访问凭证 | 🔴 必须修复 |

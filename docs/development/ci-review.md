# 自动 CI 审查配置

## 目的

本文说明如何使用 GitHub Actions 对本项目进行自动 CI 审查。当前项目优先做桌面端电商 AI 商品图生成 MVP，因此 CI 重点是：

1. 文档一致性和敏感信息扫描。
2. Vue/TypeScript 桌面前端 type-check/lint/test/build。
3. 历史 Go server scaffold 如存在则保持可测，但不是 MVP 优先方向。

## 已创建文件

```text
.github/workflows/ci-review.yml
scripts/ci/secret-scan.sh
scripts/ci/docs-check.sh
scripts/ci/migration-check.sh
scripts/ci/scaffold-build-test.sh
```

## CI 触发条件

```yaml
on:
  push:
    branches: [main, master, develop]
  pull_request:
    branches: [main, master, develop]
```

## 权限策略

当前 CI 只读仓库内容：

```yaml
permissions:
  contents: read
```

不配置真实模型服务凭证、不连接生产库、不写入外部系统。

## Job 说明

### planning-review

始终运行。

检查内容：

1. `secret-scan.sh`
   - 检查可提交文本中是否存在疑似真实密钥。
   - 排除 `.claude/settings.local.json`、`.env`、`node_modules` 等本地/构建文件。

2. `docs-check.sh`
   - 检查关键文件是否存在。
   - 检查过期描述。
   - 检查关键相对链接是否可解析。

3. `migration-check.sh`
   - 当前仅作为后续云端/SaaS SQL 参考检查。
   - MVP 不执行远程数据库变更。

### scaffold-build-test

脚手架感知型构建测试。

优先检查桌面前端：

```text
desktop/frontend/package.json
```

运行：

```bash
npm run type-check --if-present
npm run lint --if-present
npm run test --if-present
npm run build --if-present
```

## 本地运行 CI 检查

在 Git Bash 中运行：

```bash
bash scripts/ci/secret-scan.sh
bash scripts/ci/docs-check.sh
bash scripts/ci/scaffold-build-test.sh
```

桌面前端开发时优先运行：

```bash
cd desktop/frontend
npm run type-check
npm run lint
npm run test
npm run build
```

## CI 审查和 Claude 审查的关系

| 类型 | 作用 |
|------|------|
| CI 审查 | 自动、确定性、每次 push/PR 都跑 |
| Claude 审查 | 语义理解、架构判断、安全边界、修复建议 |

推荐流程：

```text
Claude 实现桌面端 MVP 功能
  ↓
本地 type-check/lint/test/build
  ↓
Claude 代码审查 + 修复
  ↓
提交 PR
  ↓
GitHub Actions 自动审查
```

## 后续扩展

当桌面端 MVP 稳定后，建议补充：

1. 前端 Vitest 覆盖率。
2. Playwright 桌面/浏览器 E2E。
3. Wails 打包检查。
4. AI Provider mock 测试。
5. 本地配置/历史迁移测试。
6. 依赖漏洞扫描。

## 安全注意事项

- CI 不存真实模型服务凭证。
- CI 不连接用户配置的 AI 中转站。
- 不使用 `pull_request_target` 运行不可信 PR 代码。

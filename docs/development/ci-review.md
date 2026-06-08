# 自动 CI 审查配置

## 目的

本文说明如何使用 GitHub Actions 对本项目进行自动 CI 审查。当前项目处于规划/脚手架准备阶段，因此 CI 采用“阶段化”策略：

1. **现在立即可用**：文档一致性、敏感信息扫描、migration 安全检查。
2. **脚手架出现后自动启用**：Go build/test/vet、Vue type-check/lint/test/build。
3. **功能开发后扩展**：覆盖率、E2E、发布前安全检查。

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

不配置数据库密码、不连接生产库、不写入外部系统。

## Job 说明

### planning-review

适用于当前规划阶段，始终运行。

检查内容：

1. `secret-scan.sh`
   - 检查可提交文本中是否存在疑似真实密钥。
   - 排除 `.claude/settings.local.json`、`.env`、`node_modules` 等本地/构建文件。

2. `docs-check.sh`
   - 检查关键文件是否存在。
   - 检查旧文件引用和过期描述。
   - 检查关键相对链接是否可解析。

3. `migration-check.sh`
   - 检查 migration 中是否存在默认禁止的危险 SQL。
   - 检查 migration 是否记录 `schema_migrations`。
   - 检查建表/建库是否使用 `utf8mb4`。

### scaffold-build-test

脚手架感知型构建测试。

如果存在：

```text
server/go.mod 或 go.mod
```

则运行 Go 检查：

```bash
go mod verify
gofmt -l .
go vet ./...
go test ./...
go build ./...
```

如果存在：

```text
desktop/frontend/package.json 或 package.json
```

则运行前端检查：

```bash
npm run type-check --if-present
npm run lint --if-present
npm run test --if-present
npm run build --if-present
```

如果脚手架不存在，则输出：

```text
No application scaffold found. Planning-stage checks only.
```

不会把“还没创建工程”当作失败。

## 本地运行 CI 检查

在 Git Bash 中运行：

```bash
bash scripts/ci/secret-scan.sh
bash scripts/ci/docs-check.sh
bash scripts/ci/migration-check.sh
bash scripts/ci/scaffold-build-test.sh
```

## CI 审查和 Claude 审查的关系

| 类型 | 作用 |
|------|------|
| CI 审查 | 自动、确定性、每次 push/PR 都跑 |
| Claude 审查 | 语义理解、架构判断、安全边界、修复建议 |

推荐流程：

```text
Claude 自动开发
  ↓
Claude 本地审查 + 修复
  ↓
本地运行 scripts/ci/*.sh
  ↓
提交 PR
  ↓
GitHub Actions 自动审查
  ↓
失败则 Claude 根据日志修复
```

## 后续扩展

当项目脚手架完成后，建议补充：

1. Go 覆盖率阈值。
2. 前端 Vitest 覆盖率。
3. Playwright E2E。
4. Docker build。
5. OpenAPI 文档生成检查。
6. migration dry-run 到临时 MySQL。
7. 依赖漏洞扫描。

## 安全注意事项

- CI 不存真实数据库密码。
- CI 不连接远程生产数据库。
- migration 执行必须由人工确认目标库。
- GitHub Secrets 后续只保存最小必要的测试环境凭据。
- 不使用 `pull_request_target` 运行不可信 PR 代码。

# Claude 自动审查配置说明

## 目的

本文定义本项目如何使用 Claude 进行自动审查、如何触发、审查范围、审查维度、输出格式，以及审查后的修复闭环。

> 注意：本文件是项目内审查规范文档，不是自动注册的 Claude Code slash command。执行审查前应显式读取本文件、`CLAUDE.md`、`DATABASE_RULES.md` 和相关代码/文档。

## 当前阶段适用范围

当前项目仍处于规划与脚手架准备阶段，审查分为两类：

| 阶段 | 可审查内容 | 不应强行执行 |
|------|------------|--------------|
| 规划阶段 | 文档、配置模板、migration、skills/workflows 规范 | Go/Vue build/test |
| 脚手架阶段 | Go/Vue 基础工程、命令、测试框架 | 生产数据库变更 |
| 功能开发阶段 | 业务代码、测试、接口、UI、迁移 | 未确认的破坏性操作 |

## 审查触发方式

### 文档/规划审查

```text
审查当前文档结构和自动开发流程
审查 docs/ 和 workflows/ 是否支持后续自动开发
```

### 功能代码审查

```text
审查最近修改的功能代码
审查 generation 模块实现
审查这次改动并给出修复建议
```

### 安全审查

```text
安全审查认证、积分和数据库相关代码
检查是否有密钥泄漏、越权访问或并发扣费问题
```

### 审查并修复

```text
审查最近修改并自动修复高置信问题
```

## 审查前置检查

执行审查前先确认：

1. 当前是否为 Git 仓库。
2. 是否存在待审查 diff。
3. 若不是 Git 仓库，则以用户指定范围为准。
4. 若审查数据库变更，必须读取 `DATABASE_RULES.md`。
5. 若审查功能代码，必须读取对应需求、架构、编码规范。
6. 若涉及敏感配置，只审查模板，不输出真实密钥。

## 审查范围

### 默认范围

```text
CLAUDE.md
README.md
DATABASE_RULES.md
.env.example
.mcp.example.json
docs/**
skills/**
workflows/**
server/migrations/**
```

### 功能开发后范围

```text
server/**
desktop/**
docs/**
server/migrations/**
```

排除：

```text
.claude/settings.local.json
.env
.env.local
node_modules/
dist/
build/
```

## 审查维度

### 1. 正确性

- 逻辑是否符合 PRD 和架构文档
- 状态流转是否完整
- 错误路径是否处理
- 幂等键是否生效
- 空值、边界条件、重试场景是否覆盖

### 2. 数据库安全

- 是否遵守 `DATABASE_RULES.md`
- 是否有危险 SQL：DROP、TRUNCATE、批量 DELETE、大范围 UPDATE
- 积分扣减是否事务 + 行锁/乐观锁
- migration 是否幂等
- 是否误把图片二进制写入 MySQL

### 3. 权限与安全

- 桌面端是否不含 OpenAI / 数据库密钥
- API 是否有认证和资源归属校验
- 团队资源是否有角色校验
- API Key 是否只存 hash
- 上传文件是否限制类型和大小

### 4. 架构一致性

- 是否符合 Wails + Vue 3 + Go Cloud API 架构
- 桌面端是否只做本地 UX、缓存、上传下载
- GPT-Image-2 是否只在云端调用
- MySQL 是否为权威状态源
- Redis/Asynq 是否只用于队列和重试

### 5. 测试与可验证性

- 是否有单元测试 / 集成测试
- 是否有可运行命令
- 是否能通过 build-verify
- 没有脚手架时是否正确 SKIP，而不是误修复

### 6. 文档一致性

- 是否有死链
- 索引是否更新
- 文件描述是否过时
- skills/workflows 是否与实际文件一致

## 输出格式

### 审查报告

```markdown
# 审查报告

## 结论

- 通过 / 需修复 / 阻塞

## 高优先级问题

| 文件 | 行号 | 问题 | 影响 | 建议 |
|------|------|------|------|------|

## 中优先级问题

...

## 低优先级建议

...

## 已跳过项

- Go build：未发现 go.mod，当前阶段跳过
- Vue test：未发现 package.json，当前阶段跳过
```

### JSON Findings（用于自动处理）

```json
[
  {
    "file": "server/internal/service/credit.go",
    "line": 42,
    "severity": "high",
    "summary": "积分扣减未使用事务和行锁",
    "failure_scenario": "并发两个 generation_job 同时扣费，余额可能被超扣",
    "suggested_fix": "使用 SELECT ... FOR UPDATE 锁定 credit_accounts 行，并在同一事务内写入 credit_transactions"
  }
]
```

## 修复闭环

```text
审查发现问题
  ↓
按严重程度排序
  ↓
高置信问题自动修复
  ↓
运行 build-verify / 文档扫描 / SQL 规则检查
  ↓
再次审查修复结果
  ↓
输出最终报告
```

## 自动修复边界

可以自动修复：

- 明确的死链
- 索引过期
- 示例代码与表结构不一致
- 编译错误中的类型/导入/拼写问题
- 测试断言明显错误

需要用户确认：

- 依赖新增或版本变更
- 数据库迁移执行
- 删除文件
- 修改认证/支付/积分核心逻辑
- 修改真实配置或密钥

禁止自动修复：

- 真实密钥
- 生产数据库危险操作
- 未确认的大范围删除
- 绕过安全校验的临时修复

## 推荐审查节奏

| 节点 | 审查类型 |
|------|----------|
| 新增需求文档后 | 文档一致性审查 |
| 新建 migration 后 | 数据库规则审查 |
| 新建模块脚手架后 | 架构/分层审查 |
| 功能实现后 | 代码正确性 + 安全 + 测试审查 |
| 发布前 | 综合审查 + 安全审查 |

## 当前缺失配置

真正实现完整自动化审查闭环，还需要后续补齐：

1. Git 仓库初始化并推送到远程仓库，方便基于 diff 审查和触发 GitHub Actions。
2. Go/Vue 脚手架，提供真实 build/test 命令。
3. 测试框架和测试命令。
4. 数据库迁移 runner 和测试库配置。
5. 功能代码实现后补充覆盖率、E2E、依赖漏洞扫描等扩展 CI。

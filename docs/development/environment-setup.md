# 开发环境搭建

## 前置依赖

### 桌面端开发

```bash
# Go 1.22+
go version

# Node.js 20+
node --version

# Wails CLI
go install github.com/wailsapp/wails/v3/cmd/wails3@latest

# pnpm (推荐)
npm install -g pnpm
```

### 云端开发

```bash
# Go 1.22+
go version

# MySQL 8.0 (开发用远程实例，见 MCP 配置)
# Redis 7.x
redis-server --version
```

## 项目结构（规划中）

```text
shadow-image/
├── desktop/                  <- Wails + Vue 3 桌面应用
│   ├── app.go               <- Wails 应用入口
│   ├── frontend/            <- Vue 3 + TS + Element Plus
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── views/
│   │   │   ├── stores/      <- Pinia
│   │   │   ├── api/         <- HTTP 客户端
│   │   │   └── composables/
│   │   └── package.json
│   ├── go.mod
│   └── wails.json
├── server/                   <- Go 云端服务
│   ├── cmd/
│   │   ├── api/             <- API 服务入口
│   │   └── worker/          <- Worker 入口
│   ├── internal/
│   │   ├── handler/         <- HTTP handlers
│   │   ├── service/         <- 业务逻辑
│   │   ├── repository/      <- 数据访问
│   │   ├── model/           <- GORM 模型
│   │   ├── middleware/      <- Gin 中间件
│   │   ├── worker/          <- Asynq 任务处理器
│   │   └── config/          <- 配置
│   ├── migrations/          <- SQL 迁移文件
│   ├── go.mod
│   └── go.sum
├── docs/                     <- 项目文档
├── skills/                   <- 自定义 Agent 技能
├── workflows/                <- Agent 编排工作流
└── deploy/                   <- 部署配置 (Docker, k8s)
```

## MCP 配置

本项目使用 `@berthojoris/mcp-mysql-server` 连接远程 MySQL。

配置文件模板见 `.mcp.example.json`，实际配置放在 `.claude/settings.local.json` 中。

## 开发流程

1. **需求确认** → 查看 `docs/product/PRD.md`
2. **架构理解** → 查看 `docs/architecture/system-design.md`
3. **编码规范** → 查看 `docs/development/coding-standards.md`
4. **Agent 开发** → 使用 `skills/` 和 `workflows/` 自动化
5. **数据库变更** → 创建新迁移文件到 `server/migrations/`
6. **代码审查** → 使用 `code-review` skill

## 环境变量

参见仓库根目录下的 `.env.example` 模板文件。

桌面端和云端各自维护独立的 `.env` 文件，均不提交到仓库（已在 `.gitignore` 中排除）。

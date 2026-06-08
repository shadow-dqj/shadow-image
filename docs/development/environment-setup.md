# 开发环境搭建

## 前置依赖

### 桌面端 MVP 开发

```bash
# Go（Wails 本地桥接需要）
go version

# Node.js 20+
node --version

# Wails CLI（后续桌面壳集成使用）
go install github.com/wailsapp/wails/v3/cmd/wails3@latest

# npm / pnpm 均可；当前 frontend 使用 npm scripts
npm --version
```

### 当前前端脚手架

```bash
cd desktop/frontend
npm install
npm run dev
npm run type-check
npm run test
npm run build

# Go Bridge 基础验证
cd ../
go test .

# Wails/Windows 桌面包最小验证
# 确保 D:\Go\bin 在 PATH 中，或显式设置：PATH="/d/Go/bin:$PATH"
wails3 build
# 输出：desktop/bin/shadow-image.exe
```

说明：Wails CLI 当前用于后续桌面壳运行/打包；A1 阶段已补齐可编译的 Wails v3 Go 入口和基础 Bridge 服务。

## 项目结构（MVP 优先）

```text
shadow-image/
├── desktop/                         <- Wails + Vue 3 桌面应用
│   ├── frontend/                    <- Vue 3 + TS + Element Plus
│   │   ├── src/
│   │   │   ├── components/          <- 通用与业务组件
│   │   │   ├── views/               <- 设置页、生图页、历史页、导出页（后续）
│   │   │   ├── stores/              <- Pinia：设置、项目、生成历史（后续）
│   │   │   ├── services/bridge/     <- Wails bridge 前端调用封装（后续）
│   │   │   ├── types/               <- TypeScript 类型（后续）
│   │   │   ├── utils/               <- 图片/Prompt/文件工具（后续）
│   │   │   └── composables/         <- useAiProvider/useGeneration 等（后续）
│   │   └── package.json
│   ├── app_service.go               <- Go Bridge 基础服务和 AppData 目录能力
│   ├── app_service_test.go          <- Go Bridge 基础测试
│   ├── main.go                      <- Wails v3 桌面入口
│   ├── go.mod                       <- Wails v3 Go module
│   └── go.sum                       <- Go 依赖锁定
├── docs/                            <- 项目文档
├── skills/                          <- 自定义 Agent 技能规范
├── workflows/                       <- Agent 编排工作流
├── server/                          <- 后续云端/SaaS 预留，MVP 暂不优先
└── scripts/ci/                      <- CI 检查脚本
```

## MVP 开发流程

1. **需求确认** → 查看 `docs/product/PRD.md`
2. **架构理解** → 查看 `docs/architecture/system-design.md`
3. **编码规范** → 查看 `docs/development/coding-standards.md`
4. **前端页面开发** → 设置页、生图页、历史页、导出页
5. **AI Provider 适配** → OpenAI-compatible / Custom Gateway
6. **本地保存** → 配置、上传图、输出图、生成历史
7. **测试与审查** → Vitest、lint、type-check、code-review

## AI Provider 本地配置

MVP 阶段由用户手动填写：

- API Base URL
- API Key
- Model
- Provider Type
- Timeout
- Default Size / Quality

实现注意：

- UI 中 API Key 必须脱敏展示。
- 不把真实 Key 写入仓库或文档。
- 请求前提示用户图片和 Prompt 会发送到其配置的服务商。
- Provider 差异用 Adapter 处理，不散落在页面组件里。

## MCP 配置

- GitHub MCP 用于仓库/PR/Issue 等操作。
- 桌面 MVP 开发不依赖数据库 MCP。

## 环境变量

参见仓库根目录下的 `.env.example`。MVP 只需要桌面端本地 AI Provider 配置，不需要提交任何真实密钥。

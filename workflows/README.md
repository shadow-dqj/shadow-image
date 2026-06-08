# Workflows 索引

本目录存放项目内约定的多 Agent 流程规范文档。它们不是自动注册的可执行 workflow；使用时需要先读取对应文件，再按阶段手动或通过 Claude Code Workflow 工具编排执行。

## 当前方向

当前 MVP 优先开发**桌面端电商 AI 商品图生成工具**。开发工作流必须围绕“上传一张商品参考图 → 生成主图 + 详情长图草案 → 本地编辑/拼接/导出”的闭环展开。

核心工程基准：

- Wails 桌面应用。
- Vue 3 + TypeScript + Element Plus UI。
- Go Bridge 负责 AppData、本地文件、外部 AI API 请求、图片下载/base64 解码、导出兜底。
- 用户自配 AI Gateway / OpenAI-compatible API。
- 本地 JSON/文件系统保存任务、历史和导出产物。
- Fabric.js/Canvas 负责详情长图预览、图层编辑和轻量导出。
- Go Image Composer 预留为超长详情图最终导出兜底。
- Windows x64、macOS arm64/amd64/Universal 作为跨平台目标。

## 开发阶段基准

```text
MVP-A：主图闭环
1. Settings + ProviderConfig + 网络/代理配置
2. Go Bridge AppData/文件系统封装
3. ProductInput + ProductContext
4. PlatformTarget + GenerationPackage
5. PromptBuilder 本地规则版
6. Go Bridge Provider Adapter 基础调用
7. MainImageTask 主图生成闭环
8. LocalHistory JSON 保存

MVP-B：详情长图 quick4
9. DetailPagePlan quick4
10. VisualStyleGuide
11. DetailSectionTask 状态机
12. 分段生成和重试
13. DetailComposer Canvas 预览
14. ExportEngine + Go Image Composer 兜底设计

MVP-C：详情长图 full8
15. full8 模板
16. 本地文字/参数表/图标图层
17. 导出包
18. Windows/macOS 打包验证
```

## 关键约束

1. 不做云端后台、用户体系、积分、订阅、服务端任务队列和服务端数据库。
2. AI Provider 调用必须经由 Go Bridge Provider Adapter，前端 WebView 不直接请求用户配置的 AI Gateway。
3. 本地路径、AppData、打开文件夹和导出路径由 Go Bridge 统一跨平台管理。
4. API Key 不写入 `job.json`、`history.json`、错误摘要或导出包。
5. 详情长图不一次性生成，必须分段生成、统一 VisualStyleGuide、本地拼接。
6. 分段失败只重试当前段，不整体重生成整张详情长图。
7. 广告文案、参数表、图标、标注线优先本地叠加，不要求模型直接生成可读文字。
8. Fabric.js/Canvas 负责预览和轻量编辑；超长图导出预留 Go Image Composer 兜底。

## 目录

```text
workflows/
├── dev/           ← 开发工作流
│   ├── full-feature-dev.md
│   ├── scaffold-new-module.md
│   ├── dev-verify-loop.md
│   └── tdd-cycle.md
├── review/        ← 审查工作流
│   └── comprehensive-review.md
└── README.md
```

## 工作流列表

| 工作流 | 文件 | MVP 使用建议 |
|--------|------|-------------|
| 全功能开发 | `dev/full-feature-dev.md` | Settings、主图闭环、quick4/full8 详情长图、导出包等完整功能 |
| 模块脚手架 | `dev/scaffold-new-module.md` | 生成桌面端 types/store/bridge service/components/views/tests/Go contract |
| 开发验证闭环 | `dev/dev-verify-loop.md` | 跑前端 type-check/lint/test/build，必要时验证 Go Bridge/Wails 构建 |
| TDD 循环 | `dev/tdd-cycle.md` | PromptBuilder、PlatformRules、ProviderCapabilities、状态机、ComposerConfig、路径工具 |
| 综合审查 | `review/comprehensive-review.md` | 审查安全边界、跨平台路径、Go Bridge、分段生成、导出兜底和业务一致性 |

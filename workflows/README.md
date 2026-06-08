# Workflows 索引

本目录存放项目内约定的多 Agent 流程规范文档。它们不是自动注册的可执行 workflow；使用时需要先读取对应文件，再按阶段手动或通过 Claude Code Workflow 工具编排执行。

## 当前方向

当前 MVP 优先开发桌面端电商 AI 商品图生成工具。工作流应围绕：

- AI Provider 设置
- 商品图上传/预览
- 提示词优化
- 平台规则与 Prompt 模板
- 单张 AI 生图调用
- 生成结果保存/历史/导出
- Fabric.js 轻量编辑

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
| 全功能开发 | `dev/full-feature-dev.md` | 设置页、生图页、提示词优化、历史页等完整功能 |
| 模块脚手架 | `dev/scaffold-new-module.md` | 生成桌面端 types/store/composable/components/views/tests |
| 开发验证闭环 | `dev/dev-verify-loop.md` | 跑前端 type-check/lint/test/build |
| TDD 循环 | `dev/tdd-cycle.md` | Provider adapter、Prompt Optimizer、平台规则、工具函数 |
| 综合审查 | `review/comprehensive-review.md` | 审查安全边界、业务一致性、UI 可维护性 |

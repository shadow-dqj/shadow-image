# Workflows 索引

本目录存放项目内约定的多 Agent 流程规范文档。它们不是自动注册的可执行 workflow；使用时需要先读取对应文件，再按阶段手动或通过 Claude Code Workflow 工具编排执行。

## 目录

```text
workflows/
├── dev/           ← 开发工作流
│   ├── full-feature-dev.md
│   ├── add-database-table.md
│   ├── scaffold-new-module.md
│   ├── dev-verify-loop.md
│   └── tdd-cycle.md
├── review/        ← 审查工作流
│   └── comprehensive-review.md
└── README.md
```

## 工作流列表

| 工作流 | 文件 | 说明 |
|--------|------|------|
| 全功能开发 | `dev/full-feature-dev.md` | 从需求到实现的完整功能开发流程 |
| 新增数据库表 | `dev/add-database-table.md` | 新表 migration + model 生成 |
| 模块脚手架 | `dev/scaffold-new-module.md` | 新模块三层代码生成 |
| 开发验证闭环 | `dev/dev-verify-loop.md` | 编译→测试→修复→验证 循环 |
| TDD 循环 | `dev/tdd-cycle.md` | Red→Green→Refactor TDD 工作流 |
| 综合审查 | `review/comprehensive-review.md` | 多 Agent 并行代码+安全检查 |

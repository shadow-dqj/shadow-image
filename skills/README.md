# Skills 索引

本目录存放项目内约定的 Claude Agent 开发技能文档（原子操作）。这些 Markdown 文件不是 Claude Code 内置 slash skill；使用前应先读取对应文件，再按其中规范执行。

## 目录

```text
skills/
├── dev/           ← 开发类技能（代码生成、验证、测试、修复）
│   ├── generate-go-model.md
│   ├── generate-api-handler.md
│   ├── generate-vue-component.md
│   ├── create-migration.md
│   ├── build-verify.md
│   ├── generate-test.md
│   └── auto-fix.md
├── review/        ← 审查类技能
│   ├── code-review.md
│   └── security-review.md
└── README.md
```

## 技能列表

| 技能 | 文件 | 说明 |
|------|------|------|
| Go Model 生成 | `dev/generate-go-model.md` | 从表结构生成 GORM 模型 |
| API Handler 生成 | `dev/generate-api-handler.md` | 生成 handler/service/repository 三层 |
| Vue 组件生成 | `dev/generate-vue-component.md` | 生成 Vue 3 组件 |
| Migration 创建 | `dev/create-migration.md` | 创建数据库迁移文件 |
| 编译验证 | `dev/build-verify.md` | 编译检查 + 静态分析 |
| 测试生成 | `dev/generate-test.md` | 生成单元测试 + 集成测试 |
| 自动修复 | `dev/auto-fix.md` | 根据错误信息自动修复代码 |
| 代码审查 | `review/code-review.md` | 代码质量审查 |
| 安全检查 | `review/security-review.md` | 安全漏洞检查 |

## 技能使用方式

在对话中直接描述需求时，应先读取本目录中最匹配的技能文档，再按规范执行：

```text
@claude 根据 generation_jobs 表生成 Go model
@claude 审查最近修改的 handler 代码
```

## 技能开发规范

每个技能文件必须包含：

1. **描述** — 功能说明
2. **触发条件** — 什么情况下使用
3. **上下文依赖** — 需要阅读的文档
4. **输入/输出** — 参数和产出
5. **示例** — 使用示例

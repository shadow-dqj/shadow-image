# Skills 索引

本目录存放项目内约定的 Claude Agent 开发技能文档（原子操作）。这些 Markdown 文件不是 Claude Code 内置 slash skill；使用前应先读取对应文件，再按其中规范执行。

## 当前方向

当前 MVP 优先开发桌面端电商 AI 商品图生成工具。使用技能时应聚焦：

- Vue 3 / TypeScript / Element Plus 组件开发
- AI Provider 设置与请求适配
- 商品图上传、提示词优化、生成结果、历史记录、导出
- 本地配置和文件保存
- 电商平台规则和 Prompt 模板

## 目录

```text
skills/
├── dev/           ← 开发类技能（组件生成、验证、测试、修复）
│   ├── generate-vue-component.md
│   ├── build-verify.md
│   ├── generate-test.md
│   └── auto-fix.md
├── review/        ← 审查类技能
│   ├── code-review.md
│   └── security-review.md
└── README.md
```

## 技能列表

| 技能 | 文件 | MVP 使用建议 |
|------|------|-------------|
| Vue 组件生成 | `dev/generate-vue-component.md` | 设置页、生图页、提示词优化面板、上传组件、结果组件 |
| 编译验证 | `dev/build-verify.md` | 验证桌面前端 type-check/lint/test/build |
| 测试生成 | `dev/generate-test.md` | 生成 Vitest/组件/工具函数测试 |
| 自动修复 | `dev/auto-fix.md` | 修复前端类型、lint、测试问题 |
| 代码审查 | `review/code-review.md` | 审查桌面端业务逻辑和可维护性 |
| 安全检查 | `review/security-review.md` | 检查本地凭证、日志脱敏、外部 API 调用、图片/Prompt 外发提示 |

## 技能使用方式

```text
@claude 生成 AI Provider 设置页组件
@claude 生成提示词优化面板
@claude 生成商品图上传组件测试
@claude 审查最近修改的桌面端代码
```

## 技能开发规范

每个技能文件必须包含：

1. **描述** — 功能说明
2. **触发条件** — 什么情况下使用
3. **上下文依赖** — 需要阅读的文档
4. **输入/输出** — 参数和产出
5. **示例** — 使用示例

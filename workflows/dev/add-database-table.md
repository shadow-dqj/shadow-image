# add-database-table

## 描述

新增数据库表的完整工作流：创建 migration → 执行 migration → 生成 model。

## 阶段

1. **Migration** — 创建 SQL 迁移文件
2. **Execute** — 通过 MCP 执行迁移
3. **Model** — 生成 Go model 文件

## Agent 编排

### Phase 1: Migration
- Agent: 根据需求生成 SQL 迁移文件

### Phase 2: Execute
- Agent: 仅在满足以下条件时通过 MySQL MCP 执行迁移：
  1. 已读取 `DATABASE_RULES.md`
  2. 用户明确确认目标数据库/环境
  3. 迁移已经过语法与安全审查
  4. 操作不包含 DROP/TRUNCATE/批量 DELETE 等危险语句
- 否则只生成迁移文件和执行说明，不直接执行

### Phase 3: Model
- Agent: 根据表结构生成 GORM model

## 使用方式

```text
@claude 创建 <表名> 表，字段包括 <字段描述>
```

## 注意事项

- 遵循 `DATABASE_RULES.md` 规范
- 新表使用 utf8mb4
- 必须包含时间戳字段
- 幂等执行（IF NOT EXISTS）

# create-migration

## 描述

创建数据库迁移文件。

## 触发条件

- 新表创建
- 表结构变更
- "创建迁移 / create migration"
- "新建表 / add table"

## 上下文依赖

- `docs/architecture/database-schema.md` — 数据库设计
- `DATABASE_RULES.md` — 数据库操作规则
- `server/migrations/` — 现有迁移

## 输入

- 表名和字段定义
- 或变更描述（用自然语言描述需要做什么）

## 输出

- `server/migrations/NNN_description.sql` — SQL 迁移文件

## 规范

1. 文件命名：`NNN_<description>.sql`（NNN 为递增序号，如 `002_add_refunds_table`）
2. 必须尽量幂等：新表使用 `CREATE TABLE IF NOT EXISTS`；变更列/索引前先通过 `information_schema` 检查是否存在，再按 MySQL 8.0 支持的语法执行 `ALTER TABLE`。不要生成无效的 `ALTER TABLE ... IF EXISTS`。
3. 新表必须使用 `utf8mb4` 字符集和 `utf8mb4_0900_ai_ci` 排序规则
4. 所有表必须有 `created_at` 和 `updated_at` 时间戳
5. 业务表建议添加 `deleted_at` 支持软删除
6. 外键必须显式声明
7. 最后插入 `schema_migrations` 记录

## 迁移模板

```sql
-- NNN: <description>
USE `shadow_image`;

-- DDL statements here

INSERT INTO `schema_migrations` (`version`, `name`)
VALUES ('NNN', '<description>')
ON DUPLICATE KEY UPDATE `applied_at` = `applied_at`;
```

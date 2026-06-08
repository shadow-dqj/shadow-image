# 数据库与 MCP 自动化规则

本项目最终采用 **Wails + Vue 3 桌面端、Go API/Worker、MySQL 8.0、Redis/Asynq、对象存储、GPT-Image-2**。

MySQL 是云端权威业务数据库；桌面端只使用 SQLite 做本地缓存，不直接连接 MySQL。

## 连接信息管理

用户已在对话中提供远程 MySQL 连接信息，用于开发初始化和 MCP 配置。后续不要把真实数据库密码写入仓库文件、方案文档、迁移文件或示例配置。

本项目默认业务库名：`shadow_image`。

推荐在 Claude Code local scope、系统环境变量或本机私有配置中维护以下字段：

- 数据库主机
- 数据库端口
- 数据库用户名
- 数据库密码
- 数据库名称

不要在可提交文件中保存真实密码。仓库内只允许保存占位说明。

## MCP 使用规则

推荐使用 Claude Code local scope 配置 MySQL MCP，避免将密码写入 `.mcp.json` 或仓库文档。

推荐 MCP 包：`@berthojoris/mcp-mysql-server`。

推荐 MCP permissions：

```text
list,read,utility,create,update,execute,ddl,transaction
```

推荐 MCP categories：

```text
database_discovery,custom_queries,schema_management,index_management,constraint_management,query_optimization,analysis,utilities,transaction_management
```

默认不启用 `delete`、`bulk_operations` 和高风险表维护类能力。确需删除、清空、修复、迁移生产数据时，先明确说明影响范围并获得用户确认。

## 数据库操作原则

1. 所有结构变更必须以迁移文件为准，不直接在业务代码中隐式建表。
2. 任何 `DROP`、`TRUNCATE`、批量 `DELETE`、大范围 `UPDATE` 操作都必须先确认。
3. 积分、订单、扣费、任务状态变更必须使用事务。
4. 积分账户扣减必须使用行锁或等价并发控制，避免并发超扣。
5. 图片文件不得存入 MySQL，只保存对象存储 key、URL、尺寸、格式、hash 和元数据。
6. JSON 字段只放扩展配置和检测结果；核心筛选字段必须独立建列并建立索引。
7. Redis/Asynq 只负责队列和重试，MySQL 必须保存权威任务状态。
8. 开发期可使用高权限账号初始化数据库；应用运行期应改用最小权限账号。

## 推荐数据库账号

正式开发时建议创建两个 MySQL 用户：

- `shadow_app`：应用运行账号，只允许 `shadow_image` 库内常规读写。
- `shadow_migrator`：迁移账号，允许 `shadow_image` 库内 DDL。

MCP 在开发期可使用迁移权限账号；生产期 MCP 应只在受控维护场景开启。

## 关键表

优先维护这些核心表：

```text
users
teams
subscriptions
credit_accounts
credit_transactions
assets
projects
generation_jobs
generation_outputs
templates
prompt_versions
platform_rules
brand_kits
export_jobs
api_keys
webhook_events
admin_audit_logs
```

## 任务状态约定

`generation_jobs.status` 建议使用：

```text
pending
queued
processing
succeeded
failed
cancelled
refunded
```

每个任务至少记录：

```text
retry_count
error_code
error_message
started_at
finished_at
created_at
updated_at
```

## 自动化开发时的数据库优先级

1. 先创建迁移系统和基础 schema。
2. 再实现用户、素材、任务、积分流水。
3. 再接入 Redis/Asynq worker。
4. 再接入 GPT-Image-2 和对象存储。
5. 最后补充支付、批量任务、质量检测和后台报表。

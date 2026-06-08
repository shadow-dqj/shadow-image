# 数据库设计

> 完整 DDL 参见：[`server/migrations/001_init_shadow_image.sql`](../../server/migrations/001_init_shadow_image.sql)

## 核心表关系

```text
teams ──┬── users ──┬── projects ──┬── assets
        │           │              │
        │           ├── generation_jobs ──┬── generation_outputs
        │           │                    │
        │           ├── credit_accounts ── credit_transactions
        │           │
        │           ├── brand_kits
        │           ├── export_jobs
        │           └── api_keys
        │
        └── subscriptions
```

## 表清单

| 表名 | 说明 | 核心字段 |
|------|------|---------|
| `teams` | 团队 | name, plan_code, status |
| `users` | 用户 | email, phone, password_hash, current_team_id |
| `team_members` | 团队成员 | team_id, user_id, role |
| `subscriptions` | 订阅 | team_id, plan_code, status, period |
| `credit_accounts` | 积分账户 | balance, reserved_balance, version (乐观锁) |
| `credit_transactions` | 积分流水 | direction, amount, balance_after, idempotency_key |
| `assets` | 素材 | storage_key, url, mime_type, width, height, sha256 |
| `projects` | 项目/SKU | name, sku, metadata |
| `templates` | 生图模板 | code, platform, image_type, prompt_template |
| `prompt_versions` | Prompt 版本 | template_id, version, model, prompt_text |
| `generation_jobs` | 生图任务 | status, model, quality, credit_charged, idempotency_key |
| `generation_outputs` | 生图输出 | job_id, asset_id, platform, quality_scores |
| `platform_rules` | 平台规则 | platform, image_type, rules (JSON) |
| `brand_kits` | 品牌工具包 | logo_asset_id, colors (JSON), fonts (JSON) |
| `export_jobs` | 导出任务 | status, export_type, platform, download_url |
| `api_keys` | API 密钥 | key_hash, scopes, expires_at |
| `webhook_events` | Webhook 事件 | source, event_type, payload, status |
| `admin_audit_logs` | 审计日志 | actor_user_id, action, target_type, ip_address |

## 关键设计原则

1. **软删除** — users, teams, projects, assets, brand_kits 使用 `deleted_at`
2. **幂等** — generation_jobs, credit_transactions 使用 `idempotency_key` UNIQUE
3. **乐观锁** — credit_accounts 使用 `version` 字段防止并发超扣
4. **CHECK 约束** — generation_jobs.status, credit_transactions.direction 使用 CHECK
5. **外键** — 核心业务表建立外键约束，保证引用完整性
6. **JSON 列** — 扩展配置和检测结果用 JSON，核心筛选字段独立建索引

## 积分事务安全

```sql
-- 扣减积分示例（必须事务+行锁）
START TRANSACTION;
SELECT balance, version FROM credit_accounts WHERE id = ? FOR UPDATE;
-- 检查余额充足
UPDATE credit_accounts SET balance = balance - ?, version = version + 1 WHERE id = ? AND version = ?;
-- 检查 affected rows = 1
INSERT INTO credit_transactions (...) VALUES (...);
COMMIT;
```

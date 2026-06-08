# generate-go-model

## 描述

根据数据库迁移文件或表结构，生成 GORM 模型文件。

## 触发条件

- 用户要求生成 Go model
- 新表创建后需要对应模型
- "生成 / create Go model / GORM model"

## 上下文依赖

- `docs/architecture/database-schema.md` — 表结构
- `docs/development/coding-standards.md` — 编码规范
- `server/migrations/` — 迁移文件

## 输入

- 表名（或多个表名）
- 或迁移文件路径

## 输出

- `server/internal/model/<table_name>.go` — GORM 模型文件
- 包含：结构体定义、GORM 标签、JSON 标签、必要的验证标签

## 规范

1. 模型名使用 PascalCase 单数（`GenerationJob` 不是 `GenerationJobs`）
2. 主键使用 `uint64`
3. 时间字段使用 `*time.Time`（可为 NULL）
4. JSON 字段使用 `datatypes.JSON` 或 `string`
5. 必须实现 `TableName()` 方法
6. 只有迁移文件中存在 `deleted_at` 字段时才添加 `gorm.DeletedAt`；不要为没有软删除列的表强行生成软删除字段。

## 示例

```go
// server/internal/model/generation_job.go
package model

import (
    "time"
    "gorm.io/datatypes"
)

type GenerationJob struct {
    ID              uint64         `gorm:"primaryKey;autoIncrement" json:"id"`
    TeamID          *uint64        `gorm:"index:idx_generation_jobs_team_status" json:"team_id"`
    UserID          uint64         `gorm:"not null;index:idx_generation_jobs_user_status" json:"user_id"`
    ProjectID       *uint64        `gorm:"index" json:"project_id"`
    InputAssetID    uint64         `gorm:"not null;index" json:"input_asset_id"`
    TemplateID      *uint64        `gorm:"" json:"template_id"`
    PromptVersionID *uint64        `gorm:"" json:"prompt_version_id"`
    JobType         string         `gorm:"type:varchar(64);not null" json:"job_type"`
    Platform        *string        `gorm:"type:varchar(64)" json:"platform"`
    Status          string         `gorm:"type:varchar(32);not null;default:pending;index:idx_generation_jobs_status" json:"status"`
    Model           string         `gorm:"type:varchar(64);not null;default:gpt-image-2" json:"model"`
    Quality         string         `gorm:"type:varchar(32);not null;default:standard" json:"quality"`
    Size            *string        `gorm:"type:varchar(32)" json:"size"`
    OutputCount     uint           `gorm:"not null;default:1" json:"output_count"`
    CostEstimate    *float64       `gorm:"type:decimal(18,6)" json:"cost_estimate"`
    ActualCost      *float64       `gorm:"type:decimal(18,6)" json:"actual_cost"`
    CreditCharged   int64          `gorm:"not null;default:0" json:"credit_charged"`
    IdempotencyKey  *string        `gorm:"type:varchar(191);uniqueIndex" json:"idempotency_key"`
    Payload         datatypes.JSON `gorm:"type:json" json:"payload"`
    RetryCount      uint           `gorm:"not null;default:0" json:"retry_count"`
    ErrorCode       *string        `gorm:"type:varchar(128)" json:"error_code"`
    ErrorMessage    *string        `gorm:"type:text" json:"error_message"`
    QueuedAt        *time.Time     `gorm:"" json:"queued_at"`
    StartedAt       *time.Time     `gorm:"" json:"started_at"`
    FinishedAt      *time.Time     `gorm:"" json:"finished_at"`
    CreatedAt       time.Time      `gorm:"not null;autoCreateTime:milli" json:"created_at"`
    UpdatedAt       time.Time      `gorm:"not null;autoUpdateTime:milli" json:"updated_at"`
}

func (GenerationJob) TableName() string {
    return "generation_jobs"
}
```

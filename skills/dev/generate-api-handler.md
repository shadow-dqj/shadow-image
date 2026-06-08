# generate-api-handler

## 描述

为指定模块生成 handler / service / repository 三层代码。

## 触发条件

- 新模块需要 API 接口
- "生成 API / create API handler"
- "新增接口 / add endpoint"

## 上下文依赖

- `docs/architecture/system-design.md` — 架构设计
- `docs/development/coding-standards.md` — 编码规范
- `server/internal/model/` — 模型定义

## 输入

- 模块名（如 `generation`）
- API 操作类型：CRUD / 自定义

## 输出

```text
server/internal/handler/<module>.go       ← HTTP handler（参数绑定+响应）
server/internal/service/<module>.go       ← 业务逻辑
server/internal/repository/<module>.go    ← 数据访问
server/internal/model/dto_<module>.go     ← 请求/响应 DTO
```

## 分层职责

### Handler
- 绑定请求参数（JSON/Query/Path）
- 调用 Service
- 返回统一格式响应

### Service
- 业务逻辑
- 事务管理
- 调用 Repository 和外部 Client

### Repository
- GORM 查询封装
- 分页/排序/过滤

## 示例请求 DTO

```go
// server/internal/model/dto_generation.go
type CreateGenerationJobReq struct {
    ProjectID    uint64 `json:"project_id" binding:"required"`
    InputAssetID uint64 `json:"input_asset_id" binding:"required"`
    TemplateCode string `json:"template_code" binding:"required"`
    Quality      string `json:"quality" binding:"omitempty,oneof=standard high ultra"`
    OutputCount  int    `json:"output_count" binding:"omitempty,min=1,max=10"`
}
```

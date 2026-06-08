# 编码规范

## Go 代码规范

### 项目结构

```text
server/
├── cmd/
│   ├── api/main.go          ← API 入口
│   └── worker/main.go       ← Worker 入口
├── internal/
│   ├── handler/             ← HTTP 处理器（薄层，只做参数绑定和响应）
│   ├── service/             ← 业务逻辑（核心逻辑放这里）
│   ├── repository/          ← 数据访问（GORM 查询封装）
│   ├── model/               ← 数据库模型 / DTO
│   ├── middleware/           ← Gin 中间件
│   ├── worker/              ← Asynq 任务处理器
│   ├── client/              ← 外部服务客户端 (GPT-Image-2, Storage)
│   ├── config/              ← 配置加载
│   └── pkg/                 ← 可复用工具包
│       ├── errcode/         ← 错误码定义
│       ├── response/        ← 统一响应格式
│       └── validator/       ← 参数校验
├── migrations/              ← SQL 迁移文件
└── go.mod
```

### 命名规范

- 包名：小写，单数，简短（`handler` 不是 `handlers`）
- 接口：单方法接口以 `-er` 结尾（`Generator`, `Uploader`）
- 变量：驼峰，缩写全大写（`userID`, `httpClient`）
- 常量：驼峰，不要全大写
- 错误：`errors.New` / `fmt.Errorf` 用小写开头，不加标点

### 分层规范

```text
Handler  → 参数绑定、权限校验、调用 Service、返回响应
Service  → 业务逻辑、事务管理、调用 Repository 和外部 Client
Repository → 数据库查询、GORM 操作封装
Model    → 结构体定义、GORM 标签、JSON 标签
```

### 错误处理

```go
// 定义错误码
var (
    ErrInsufficientCredit = errcode.New(40001, "积分不足")
    ErrTaskNotFound       = errcode.New(40401, "任务不存在")
)

// Service 返回业务错误
func (s *GenerationService) Create(ctx context.Context, req CreateReq) (*GenerationJob, error) {
    if balance < req.Cost {
        return nil, ErrInsufficientCredit
    }
    // ...
}

// Handler 统一响应
func (h *GenerationHandler) Create(c *gin.Context) {
    job, err := h.svc.Create(c.Request.Context(), req)
    if err != nil {
        response.Error(c, err)
        return
    }
    response.Success(c, job)
}
```

### 数据库操作

- 所有写操作必须显式使用事务
- 积分扣减使用 `SELECT ... FOR UPDATE` + version 乐观锁
- 幂等操作使用 `INSERT ... ON DUPLICATE KEY UPDATE`

## Vue/TypeScript 规范

### 目录结构

```text
desktop/frontend/src/
├── api/              ← HTTP 请求封装
├── components/       ← 可复用组件
│   ├── common/       ← 通用组件 (Button, Modal 等)
│   └── business/     ← 业务组件 (ImageUploader, TemplatePicker)
├── composables/      ← 组合式函数
├── layouts/          ← 布局组件
├── router/           ← 路由配置
├── stores/           ← Pinia stores
├── types/            ← TypeScript 类型定义
├── utils/            ← 工具函数
└── views/            ← 页面组件
```

### 命名规范

- 组件文件：PascalCase（`ImageUploader.vue`）
- 组合式函数：`use` 前缀驼峰（`useGeneration.ts`）
- Store：`use` 前缀 + Store 后缀（`useUserStore.ts`）
- 类型/接口：PascalCase（`GenerationJob`, `CreateJobReq`）
- 常量：UPPER_SNAKE 或 enum

### 组件规范

```vue
<script setup lang="ts">
// 1. imports
// 2. props/emits
// 3. composables
// 4. reactive state
// 5. computed
// 6. methods
// 7. lifecycle
</script>

<template>
  <!-- template -->
</template>

<style scoped>
/* scoped styles */
</style>
```

## Git 规范（规划中）

```text
feat:     新功能
fix:      Bug 修复
docs:     文档变更
style:    代码格式
refactor: 重构
test:     测试
chore:    构建/工具变更
```

## 数据库规范

详见 [DATABASE_RULES.md](../../DATABASE_RULES.md)

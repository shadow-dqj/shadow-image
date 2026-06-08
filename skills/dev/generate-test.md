# generate-test

## 描述

为指定的 Go/TypeScript 代码生成单元测试和集成测试。

## 触发条件

- "生成测试 / generate test / write test"
- "为这个函数写测试 / add test coverage"
- 新代码生成后需要测试
- "补充测试覆盖 / add missing tests"

## 上下文依赖

- 被测试的源文件
- `docs/development/coding-standards.md`
- 项目已有的测试文件（学习风格）

## Go 测试规范

### 框架

- `testing` 标准库
- `testify/assert` + `testify/require` 断言
- `httptest` HTTP 测试
- `go-sqlmock` 数据库测试

### 文件组织

```text
server/internal/service/generation.go
server/internal/service/generation_test.go
```

### 测试结构

```go
func TestGenerationService_Create(t *testing.T) {
    // 1. setup: 创建 mock 对象
    // 2. 给定输入
    // 3. 执行被测函数
    // 4. 验证输出
}
```

### 覆盖要求

| 类型 | 覆盖要求 |
|------|---------|
| Service | 正常路径 + 边界 + 错误路径 |
| Repository | CRUD + 事务回滚 |
| Handler | 请求绑定 + 状态码 + 响应体 |
| Middleware | 各分支路径 |

### Service 测试示例

```go
func TestGenerationService_Create(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    mockRepo := mock.NewMockGenerationRepository(ctrl)
    mockCreditCli := mock.NewMockCreditClient(ctrl)
    svc := NewGenerationService(mockRepo, mockCreditCli)

    t.Run("success", func(t *testing.T) {
        req := CreateGenReq{ProjectID: 1, TemplateCode: "amazon_main"}
        mockCreditCli.EXPECT().Reserve(gomock.Any(), gomock.Any()).Return(nil)
        mockRepo.EXPECT().Create(gomock.Any(), gomock.Any()).Return(&GenerationJob{ID: 1}, nil)

        job, err := svc.Create(context.Background(), req)
        require.NoError(t, err)
        assert.Equal(t, uint64(1), job.ID)
    })

    t.Run("insufficient_credit", func(t *testing.T) {
        req := CreateGenReq{ProjectID: 1, TemplateCode: "amazon_main"}
        mockCreditCli.EXPECT().Reserve(gomock.Any(), gomock.Any()).Return(ErrInsufficientCredit)

        _, err := svc.Create(context.Background(), req)
        assert.ErrorIs(t, err, ErrInsufficientCredit)
    })
}
```

## Vue 测试规范

### 框架

- Vitest (单元测试)
- @vue/test-utils (组件测试)
- Playwright (E2E 测试，保留)

### 文件组织

```text
desktop/frontend/src/components/business/ImageUploader.vue
desktop/frontend/src/components/business/__tests__/ImageUploader.spec.ts
```

### 覆盖要求

| 类型 | 覆盖要求 |
|------|---------|
| 组件 | Props/Emits/Slots + 用户交互 |
| Store | State/Getter/Action 各路径 |
| Composable | 正常 + 异常路径 |
| API 封装 | Mock 请求 + 错误处理 |

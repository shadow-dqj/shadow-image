# scaffold-new-module

## 描述

为新模块生成三层代码脚手架：handler / service / repository。

## 阶段

1. **Analyze** — 分析模块需求和现有代码模式
2. **Generate** — 生成三层代码 + DTO
3. **Register** — 注册路由

## Agent 编排

### Phase 1: Analyze
- Agent: 阅读现有 handler/service/repository 示例

### Phase 2: Generate (contract-first)
- Agent 1: 先生成模块契约（DTO 名称、接口方法、路由、错误码、事务边界）
- Agent 2: 根据同一契约生成 repository 文件
- Agent 3: 根据同一契约生成 service 文件
- Agent 4: 根据同一契约生成 handler 文件
- Agent 5: 根据同一契约生成 DTO 文件

> 不要在缺少共享契约时并行生成各层，否则容易出现方法名、类型和包路径不一致。

### Phase 3: Register
- Agent: 在路由文件中注册新接口

## 使用方式

```text
@claude 为 <模块名> 创建 CRUD 接口
@claude 为 generation 模块创建 API
```

## 输出

```text
server/internal/handler/<module>.go
server/internal/service/<module>.go
server/internal/repository/<module>.go
server/internal/model/dto_<module>.go
router.go 路由注册更新
```

# Claude 自动审查配置

## 当前审查重点

当前项目优先做**桌面端电商 AI 商品图生成 MVP**，审查应围绕：

1. AI Provider 设置是否安全、清晰、可测试。
2. 用户填写的模型服务地址、访问凭证、模型名是否只在本地使用。
3. 商品参考图上传、预览、保存流程是否可靠。
4. Prompt/平台规则是否能体现电商图片生成业务价值。
5. AI 请求错误处理是否用户可理解。
6. 生成结果是否能本地保存、预览、导出。
7. TypeScript 类型、Pinia 状态、Vue 组件是否清晰可维护。

## 审查阶段

### 1. MVP 桌面功能审查

适用于：

- 设置页
- 生图页
- 图片上传组件
- Prompt 编辑器
- 结果预览组件
- 历史记录
- 导出功能

重点检查：

- 是否避免在日志和错误中泄露完整访问凭证。
- Provider 差异是否封装在 adapter/provider 层。
- 页面组件是否过度承担请求拼装和业务逻辑。
- 是否有 loading、错误、重试、取消/禁用状态。
- 是否保留商品主体一致性的 Prompt 约束。

### 2. 架构一致性审查

确认改动符合当前方向：

```text
桌面端本地工具优先
用户手动配置 AI 中转站/API
服务端能力不进入当前实现范围
```

如果代码开始引入用户体系、服务端接口、远程数据库、管理后台等能力，应先确认是否偏离当前桌面 MVP 目标。

### 3. 质量审查

- Vue 组件职责单一。
- TypeScript 类型准确。
- Store 不混杂 UI 细节和 Provider 细节。
- Prompt 预设集中维护。
- 平台规则集中维护。
- 测试覆盖关键逻辑：Provider 请求构造、错误转换、Prompt 生成、组件基础状态。

## 推荐本地验证

```bash
cd desktop/frontend
npm run type-check
npm run lint
npm run test
npm run build
```

## 审查输出格式

```markdown
# Review Report

## Summary
- 本次改动是否符合桌面端 AI 生图 MVP 方向

## Findings
### [severity] 问题标题
- 文件：path/to/file
- 问题：...
- 建议：...

## MVP Fit
- 是否聚焦电商图片生成业务
- 是否避免过早引入云端/后台复杂度

## Verification
- 已执行命令
- 结果
```

## 自动修复边界

可以自动修复：

- TypeScript 类型错误
- 简单组件拆分
- 明显的 lint 问题
- Provider 错误处理改进
- Prompt/平台规则常量整理

需要用户确认：

- 改变 AI 请求协议
- 改变本地凭证保存方式
- 引入服务端接口或管理后台
- 大范围 UI 布局调整

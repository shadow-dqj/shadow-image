# security-review (skill)

## 描述

对桌面端代码和配置进行安全检查，重点关注用户手动填写的 AI 中转站/API 配置、本地凭证保存、图片/Prompt 外发提示和前端安全。

## 触发条件

- "安全检查 / security review"
- 新功能上线前
- 涉及 AI Provider 配置、访问凭证、本地文件、图片上传、外部 API 调用的变更

## 上下文依赖

- `CLAUDE.md` — 当前桌面 MVP 方向
- `docs/architecture/system-design.md` — 安全边界
- `docs/product/PRD.md` — AI Provider 和隐私要求

## 检查清单

### 本地凭证管理
- [ ] 无硬编码访问凭证、密码、Token
- [ ] AI API Key 只由用户手动填写
- [ ] UI 中 API Key 脱敏展示
- [ ] 日志、错误、测试快照不输出完整 Key
- [ ] `.env.example` 不含真实凭证

### AI Provider 调用安全
- [ ] 调用前明确用户图片和 Prompt 会发送到其配置的服务商
- [ ] Base URL 有基本格式校验
- [ ] 请求超时可配置，避免长时间卡死
- [ ] 错误信息用户可理解且不泄露敏感信息
- [ ] Provider 差异封装在 adapter 层，页面不直接拼接复杂请求

### 文件与图片安全
- [ ] 上传文件限制类型和大小
- [ ] 不把图片二进制写入日志
- [ ] 本地输出路径可控，不覆盖用户未确认文件
- [ ] 文件名处理避免路径穿越

### 前端安全
- [ ] Vue 模板默认转义，不使用不可信 `v-html`
- [ ] 用户输入的 Prompt 不作为 HTML 注入
- [ ] localStorage/配置文件保存策略清晰
- [ ] 依赖新增需关注许可证和维护状态

### 业务安全
- [ ] Prompt 明确保持商品主体不变
- [ ] 平台规则不误导用户违反平台规范
- [ ] 生成失败不会产生错误历史或覆盖旧结果

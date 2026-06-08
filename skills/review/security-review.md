# security-review (skill)

## 描述

对代码和配置进行安全检查。

## 触发条件

- "安全检查 / security review"
- 新功能上线前
- 涉及支付/认证/数据库的变更

## 上下文依赖

- `docs/architecture/system-design.md` — 安全边界
- `DATABASE_RULES.md` — 数据库安全规则

## 检查清单

### 密钥管理
- [ ] 无硬编码密钥/密码/Token
- [ ] OpenAI API Key 只在云端
- [ ] 数据库密码不在仓库中
- [ ] `.env.example` 不含真实密码

### 认证/鉴权
- [ ] Handler 层有认证中间件
- [ ] 用户只能操作自己的资源
- [ ] 团队操作有角色检查

### 数据库安全
- [ ] 积分操作有事务+行锁
- [ ] 幂等操作有去重键
- [ ] 无 SQL 拼接（使用参数化查询）
- [ ] 敏感字段加密存储

### API 安全
- [ ] HTTPS 强制
- [ ] CORS 配置正确
- [ ] Rate limiting
- [ ] 输入校验
- [ ] 文件上传大小/类型限制

### 前端安全
- [ ] XSS 防护（Vue 默认转义）
- [ ] 无 localStorage 存 Token（用 httpOnly cookie）
- [ ] CSRF Token

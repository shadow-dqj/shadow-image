# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

This repository is the development workspace for an ecommerce AI product-image generation desktop application. GitHub remote: `https://github.com/shadow-dqj/shadow-image.git`.

Current product direction: **desktop-only MVP**. The app is a local desktop tool where the user manually configures an AI gateway/model API Base URL, API Key, and model name. Development should focus on ecommerce product-image generation business value.

Key directories:

- `desktop/frontend/` — Vue 3 + TypeScript + Element Plus + Fabric.js UI
- `docs/` — product, architecture, development documentation
- `skills/` — custom Claude Code Agent skill specifications
- `workflows/` — multi-agent workflow specifications
- `scripts/ci/` — CI check scripts
- `.claude/` — Claude Code configuration
- `.github/workflows/` — GitHub Actions CI/CD
- `.env.example` — non-secret environment/config template
- `.mcp.json` — project MCP config (gitignored, contains secrets)

Application scaffold exists: Vue 3 frontend. Future development should prioritize the desktop frontend and Wails local bridge.

## Common commands

### Vue frontend

```bash
cd desktop/frontend
npm install                           # install dependencies
npm run dev                           # Vite dev server
npm run build                         # type-check + production build
npm run type-check                    # vue-tsc type check
npm run test                          # Vitest unit tests (--run)
npm run lint                          # ESLint
```

### Git push

```bash
# GitHub pushes require proxy (HTTPS 443 blocked on current network)
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897
git push

# Remote: https://github.com/shadow-dqj/shadow-image.git (master → origin)
```

## MVP product architecture

```text
Wails desktop app
  → Vue 3 UI
  → Element Plus components
  → Fabric.js canvas/editor
  → local config and local file system
  → user-configured AI gateway API
```

MVP user flow:

```text
打开桌面工具
  → 设置 AI Provider（Base URL / API Key / Model / 类型）
  → 上传商品参考图
  → 选择电商平台和图片类型
  → 输入或套用 Prompt
  → 调用用户配置的 AI 中转站接口
  → 预览生成结果
  → 本地保存 / 导出
```

## MVP AI provider rules

The desktop app calls the user's configured AI gateway directly. This is an intentional product decision for a local/bring-your-own-key desktop tool.

Required settings:

- API Base URL
- API Key
- Model name
- Provider type: OpenAI-compatible or custom gateway
- Request timeout
- Default image size/quality

Security notes:

- API keys are user-supplied and stored locally only.
- Do not commit real API keys.
- Prefer masked display for API keys in UI.
- Add local encryption or OS keychain later if needed.

## Product priorities

Focus on ecommerce image-generation business value:

1. Product reference image upload and preview.
2. Platform presets: Amazon, Shopify, TikTok, 抖音, 小红书.
3. Image types: white-background main image, lifestyle scene, vertical ad, social cover.
4. Prompt template, prompt optimization, and negative prompt editing.
5. Manual AI provider/gateway configuration.
6. Single-image generation first; batch SKU workflow later.
7. Local result history and export.
8. Lightweight editing/composition with Fabric.js.

## Documentation structure

```text
docs/
├── product/              ← product requirements, MVP specs, user stories
├── architecture/         ← desktop architecture, AI provider, local storage
├── development/          ← environment setup, coding standards, agent automation
└── decisions/            ← architecture decision records (ADR)
```

## Skills and workflows

```text
skills/
├── dev/                  ← development skill specifications
└── review/               ← review skill specifications

workflows/
├── dev/                  ← development workflow specifications
└── review/               ← review workflow specifications
```

When implementing features, prefer desktop/Vue/Wails/local AI provider tasks.

## Desktop MVP modules

```text
Settings        AI provider/gateway URL, key, model, timeout, defaults
Upload          local product image upload, validation, preview
Project         local project/SKU grouping
Prompt          platform prompt presets, user prompt editing, negative rules
PromptOptimizer product info + platform rules → optimized prompt and negative prompt
Generation      direct AI gateway call, result parsing, retry, error handling
Canvas          Fabric.js preview, overlay text, crop/resize/light edits
History         local generation records and output files
Export          save images by platform size/format
PlatformRules   local Amazon/Shopify/TikTok/抖音/小红书 presets
```

## Product constraints

- Prompt optimization should turn rough user intent into structured ecommerce image prompts before generation.
- Product-reference images should be used whenever possible; avoid pure text-to-image for real product outputs.
- Generated outputs should preserve product shape, color, material, logo, packaging text, and visible details.
- Advertising text should usually be added by the editor/template layer, not generated directly into the image.
- Background removal, white-background layout, resizing, compression, and text composition should use deterministic/local processing when possible.
- Batch SKU workflows are important but should follow after the single-image MVP works.
- Platform-rule validation is part of the value proposition.
- Cost controls in MVP are user-facing: show estimated request type, allow model/quality selection, and avoid unnecessary regenerations.

## Documentation style

Current project documentation is in Chinese. Keep product documents, rules, and user-facing planning material in Chinese unless the user asks for another language.

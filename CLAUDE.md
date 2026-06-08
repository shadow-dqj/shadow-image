# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

This repository is the development workspace for an ecommerce AI product-image generation desktop application. Git is initialized (2 commits on `master`).

Key directories:

- `docs/` — product, architecture, development documentation
- `skills/` — custom Claude Code Agent skills
- `workflows/` — multi-agent workflow definitions
- `server/` — Go API + worker (cmd/api, cmd/worker, internal/)
- `server/migrations/` — MySQL migration files
- `desktop/frontend/` — Vue 3 + Element Plus + Fabric.js UI
- `scripts/ci/` — CI check scripts
- `.claude/` — Claude Code configuration
- `.github/workflows/` — GitHub Actions CI/CD
- `.env.example` — environment variable template (non-secret)
- `.mcp.example.json` — MCP configuration template (non-secret)
- `.mcp.json` — project MCP config (gitignored, contains secrets)

Application scaffold exists: Go API server (net/http), Go worker (stub), Vue 3 frontend. Tests pass for both server and frontend.

## Common commands

### Go server

```bash
cd server
go test ./...                         # run all tests
go vet ./...                          # static analysis
go fmt ./...                          # format code
go run ./cmd/api                      # start API server
go run ./cmd/worker                   # start worker (stub)
```

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

### Database

```bash
# Migrations applied via mysql-shadow-image MCP (MySQL on shadowdu.bbroot.com:13301)
# See DATABASE_RULES.md for operational rules
```

### Git push

```bash
# GitHub pushes require proxy (HTTPS 443 blocked on current network)
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897
git push

# Remote: https://github.com/shadow-dqj/shadow-image.git (master → origin)
```

## Documentation structure

```text
docs/
├── product/              ← product requirements, feature specs, user stories
│   ├── PRD.md            ← product requirements document
│   └── ...
├── architecture/         ← system design, tech stack, database schema
│   ├── system-design.md  ← overall system architecture
│   ├── tech-stack.md     ← technology decisions
│   ├── database-schema.md← database design
│   └── ...
├── development/          ← environment setup, coding standards, agent automation
│   ├── environment-setup.md
│   ├── coding-standards.md
│   └── agent-automation.md
└── decisions/            ← architecture decision records (ADR)
    └── template.md
```

## Skills and workflows

```text
skills/
├── dev/                  ← development skills
│   ├── generate-go-model.md
│   ├── generate-api-handler.md
│   ├── generate-vue-component.md
│   ├── create-migration.md
│   ├── build-verify.md
│   ├── generate-test.md
│   └── auto-fix.md
└── review/               ← review skills
    ├── code-review.md
    └── security-review.md

workflows/
├── dev/                  ← development workflows
│   ├── full-feature-dev.md
│   ├── add-database-table.md
│   ├── scaffold-new-module.md
│   ├── dev-verify-loop.md
│   └── tdd-cycle.md
└── review/               ← review workflows
    └── comprehensive-review.md
```

## Product and architecture

### Target architecture

```text
Wails desktop app
  → Vue 3 UI
  → Go local desktop bridge
  → local SQLite cache and local file system
  → HTTPS cloud API

Cloud Go API
  → MySQL 8.0 authoritative business database
  → Redis + Asynq task queue
  → Go Worker
  → image preprocessing / background removal
  → OpenAI GPT-Image-2 generation/editing
  → post-processing and platform-rule validation
  → object storage + CDN
```

### Tech stack

**Desktop:** Wails + Vue 3 + TypeScript + Element Plus + Fabric.js
**Cloud:** Go + Gin + GORM + MySQL 8.0 + Redis + Asynq
**AI:** OpenAI GPT-Image-2 (cloud only)
**Storage:** Object storage (OSS/COS/R2/S3) + CDN

### Security boundary

The desktop app must not call GPT-Image-2 directly and must not contain OpenAI or database secrets. Desktop responsibilities are local file UX, preview, lightweight editing, local cache, upload/download, and API calls. Cloud responsibilities are authentication, billing/credits, templates/prompts, generation tasks, GPT-Image-2 calls, object storage, and authoritative task status.

## MySQL and MCP

Default database name: `shadow_image`.

MySQL host: `shadowdu.bbroot.com:13301` (via factory MCP config).

MySQL MCP package: `@benborla29/mcp-server-mysql`.

This project's MySQL MCP is configured in the factory-level `C:\Users\shado\.factory\mcp.json` as `mysql-shadow-image`. It is not defined in the project `.mcp.json` to avoid duplicate server registration.

Project `.mcp.json` contains only the `github` MCP server (`@modelcontextprotocol/server-github`).

## Key backend modules

```text
Auth        authentication and sessions
User        users, teams, device authorization
Asset       uploaded/generated image assets
Upload      signed upload and local/cloud transfer flow
Project     projects, SKU groups, batch catalogs
Generation  generation jobs, worker payloads, outputs
Template    platform/style/image templates
Prompt      prompt templates and prompt versions
Credit      credit balance and transactions
Billing     subscriptions and payments
Storage     object storage and CDN URL handling
Moderation  image/content safety checks
Export      ZIP and platform-specific export packages
Admin       operational dashboard and review tools
Webhook     async callbacks and external integrations
```

## Key database tables

```text
users
teams
subscriptions
credit_accounts
credit_transactions
assets
projects
generation_jobs
generation_outputs
templates
prompt_versions
platform_rules
brand_kits
export_jobs
api_keys
webhook_events
admin_audit_logs
```

## Product constraints

- GPT-Image-2 is the primary cloud generation/editing engine.
- Product-reference images should be used whenever possible; avoid pure text-to-image for real product outputs.
- Generated outputs should preserve product shape, color, material, logo, packaging text, and visible details.
- Advertising text should usually be added by the editor/template layer, not generated directly into the image.
- Background removal, white-background layout, resizing, compression, and text composition should use cheaper deterministic services when possible.
- Batch SKU workflows are a core paid feature.
- Platform-rule validation is part of the value proposition.
- Cost controls are required: low-cost preview before high-quality output, quality tiers, async/batch jobs, retry limits.
- MySQL is authoritative for business data. Redis/Asynq is for queues, retries, and worker coordination only.
- Credit/accounting changes must be transactional and concurrency-safe.

## Documentation style

Current project documentation is in Chinese. Keep product documents, rules, and user-facing planning material in Chinese unless the user asks for another language.

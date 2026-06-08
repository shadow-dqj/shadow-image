# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

This repository is currently a planning workspace for an ecommerce AI product-image generation desktop application. It is not a git repository yet.

Key directories:

- `docs/` — product, architecture, development documentation
- `skills/` — custom Claude Code Agent skills
- `workflows/` — multi-agent workflow definitions
- `server/migrations/` — MySQL migration files
- `.claude/` — Claude Code configuration
- `.env.example` — environment variable template (non-secret)
- `.mcp.example.json` — MCP configuration template (non-secret)

There is no application scaffold, `package.json`, `go.mod`, or test suite yet.

## Common commands

No build, lint, dev-server, migration, or test commands are currently defined.

When implementation starts, add real commands here for:

- Wails desktop development and build.
- Vue frontend install/lint/typecheck/test.
- Go API server run/test.
- Go worker run/test.
- MySQL migration up/down/status.
- Redis/Asynq worker development.

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

MySQL MCP package: `@berthojoris/mcp-mysql-server`.

Recommended permissions: `list,read,utility,create,update,execute,ddl,transaction`

Recommended categories: `database_discovery,custom_queries,schema_management,index_management,constraint_management,query_optimization,analysis,utilities,transaction_management`

Do not enable destructive permissions such as `delete`, broad bulk operations, or dangerous table maintenance by default. Read `DATABASE_RULES.md` before performing database changes.

Do not write the real password into committed/shared files. Use `.claude/settings.local.json` for secrets.

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

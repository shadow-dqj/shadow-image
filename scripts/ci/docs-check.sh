#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Documentation link and stale reference check =="

required_files=(
  "README.md"
  "CLAUDE.md"
  "DATABASE_RULES.md"
  ".env.example"
  ".mcp.example.json"
  "docs/product/PRD.md"
  "docs/architecture/system-design.md"
  "docs/architecture/tech-stack.md"
  "docs/architecture/database-schema.md"
  "docs/development/environment-setup.md"
  "docs/development/coding-standards.md"
  "docs/development/agent-automation.md"
  "docs/development/review-automation.md"
  "docs/development/feature-implementation-docs.md"
  "docs/development/ci-review.md"
  ".github/workflows/ci-review.yml"
  "scripts/ci/secret-scan.sh"
  "scripts/ci/docs-check.sh"
  "scripts/ci/migration-check.sh"
  "scripts/ci/scaffold-build-test.sh"
  "server/migrations/001_init_shadow_image.sql"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file"
    exit 1
  fi
done

if grep -RInE \
  --exclude-dir=.git \
  --exclude-dir=.claude \
  --exclude-dir=node_modules \
  --include='*.md' \
  'AUTOMATION_CONTEXT|电商AI生图软件方案|mysql配置|berthojoris-mcp-mysql-server-1\.43\.0|\.codex|generate-model|自动匹配对应技能|Agent 自动从以下文件' \
  .; then
  echo "Stale documentation reference found."
  exit 1
fi

# 检查常见相对链接目标。
links=(
  "docs/development/coding-standards.md:../../DATABASE_RULES.md"
  "docs/architecture/database-schema.md:../../server/migrations/001_init_shadow_image.sql"
)

for item in "${links[@]}"; do
  source_file="${item%%:*}"
  link_target="${item#*:}"
  source_dir="$(dirname "$source_file")"
  if [[ ! -f "$source_dir/$link_target" ]]; then
    echo "Broken link target from $source_file -> $link_target"
    exit 1
  fi
done

echo "Documentation check passed."

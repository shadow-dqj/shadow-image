#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Documentation link and stale reference check =="

required_files=(
  "README.md"
  "CLAUDE.md"
  ".env.example"
  "docs/product/PRD.md"
  "docs/product/agent-image-workflow.md"
  "docs/architecture/system-design.md"
  "docs/architecture/tech-stack.md"
  "docs/development/environment-setup.md"
  "docs/development/coding-standards.md"
  "docs/development/agent-automation.md"
  "docs/development/review-automation.md"
  "docs/development/feature-implementation-docs.md"
  "docs/development/ci-review.md"
  ".github/workflows/ci-review.yml"
  "scripts/ci/secret-scan.sh"
  "scripts/ci/docs-check.sh"
  "scripts/ci/scaffold-build-test.sh"
  "desktop/frontend/package.json"
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
  'AUTOMATION_CONTEXT|电商AI生图软件方案|mysql配置|berthojoris-mcp-mysql-server|\.codex|generate-model|自动匹配对应技能|Agent 自动从以下文件|database-schema\.md|DATABASE_RULES\.md|server/migrations|Go \+ Gin|GORM|Asynq' \
  .; then
  echo "Stale documentation reference found."
  exit 1
fi

echo "Documentation check passed."

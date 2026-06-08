#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Desktop frontend build/test =="

run_node_checks() {
  local dir="$1"
  echo "Running Node/Vue checks in $dir"
  (
    cd "$dir"
    if [[ -f package-lock.json ]]; then
      npm ci
    elif [[ -f pnpm-lock.yaml ]]; then
      corepack enable
      pnpm install --frozen-lockfile
    elif [[ -f yarn.lock ]]; then
      corepack enable
      yarn install --frozen-lockfile
    else
      npm install
    fi
    npm run type-check --if-present
    npm run lint --if-present
    npm run test --if-present
    npm run build --if-present
  )
}

if [[ -f desktop/frontend/package.json ]]; then
  run_node_checks "desktop/frontend"
elif [[ -f package.json ]]; then
  run_node_checks "."
else
  echo "Node/Vue scaffold missing; skipped frontend checks."
fi

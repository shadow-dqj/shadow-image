#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Scaffold-aware build/test =="

ran_any=0

run_go_checks() {
  local dir="$1"
  echo "Running Go checks in $dir"
  (
    cd "$dir"
    go mod verify
    gofmt_files="$(gofmt -l .)"
    if [[ -n "$gofmt_files" ]]; then
      echo "Files need gofmt:"
      echo "$gofmt_files"
      exit 1
    fi
    go vet ./...
    go test ./...
    go build ./...
  )
}

if [[ -f server/go.mod ]]; then
  ran_any=1
  run_go_checks "server"
elif [[ -f go.mod ]]; then
  ran_any=1
  run_go_checks "."
else
  echo "Go scaffold missing; skipped Go checks."
fi

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
      echo "No frontend lockfile found; install step skipped. Add package-lock.json/pnpm-lock.yaml/yarn.lock for CI installs."
    fi
    npm run type-check --if-present
    npm run lint --if-present
    npm run test --if-present
    npm run build --if-present
  )
}

if [[ -f desktop/frontend/package.json ]]; then
  ran_any=1
  run_node_checks "desktop/frontend"
elif [[ -f package.json ]]; then
  ran_any=1
  run_node_checks "."
else
  echo "Node/Vue scaffold missing; skipped frontend checks."
fi

if [[ "$ran_any" -eq 0 ]]; then
  echo "No application scaffold found. Planning-stage checks only."
fi

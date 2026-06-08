#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Secret scan =="

# 检查已知明文密码/API Key 形态。这里只扫描可提交文本，不扫描 .claude/settings.local.json。
if grep -RInE \
  --exclude-dir=.git \
  --exclude-dir=.claude \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=build \
  --include='*.md' \
  --include='*.json' \
  --include='*.sql' \
  --include='*.example' \
  --include='*.env' \
  '1qaz@WSX|sk-[A-Za-z0-9]{20,}|DB_PASSWORD[[:space:]]*[:=][[:space:]]*["'"'']?[^<[:space:]]|OPENAI_API_KEY[[:space:]]*[:=][[:space:]]*["'"'']?[^<[:space:]]|SECRET_KEY[[:space:]]*[:=][[:space:]]*["'"'']?[^<[:space:]]|JWT_SECRET[[:space:]]*[:=][[:space:]]*["'"'']?[^<[:space:]]' \
  .; then
  echo "Secret-like value found. Replace it with a placeholder before committing."
  exit 1
fi

echo "Secret scan passed."

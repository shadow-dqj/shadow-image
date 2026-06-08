#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Secret scan =="

# 只扫描 Git 可提交文件：tracked + untracked，并遵守 .gitignore。
# 这样不会扫描本地私有 .mcp.json、.env、node_modules 等文件。
mapfile -t files < <(
  git ls-files -co --exclude-standard \
    | grep -E '(\.md$|\.json$|\.sql$|\.example$|\.env$)' \
    | grep -v '^scripts/ci/secret-scan.sh$' \
    | while read -r file; do [[ -f "$file" ]] && printf '%s\n' "$file"; done || true
)

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No text config/docs files to scan."
  exit 0
fi

if grep -nE \
  'sk-[A-Za-z0-9]{20,}|DB_PASSWORD[[:space:]]*[:=][[:space:]]*["'"'"']?[^<[:space:]]|OPENAI_API_KEY[[:space:]]*[:=][[:space:]]*["'"'"']?[^<[:space:]]|SECRET_KEY[[:space:]]*[:=][[:space:]]*["'"'"']?[^<[:space:]]|JWT_SECRET[[:space:]]*[:=][[:space:]]*["'"'"']?[^<[:space:]]' \
  "${files[@]}"; then
  echo "Secret-like value found. Replace it with a placeholder before committing."
  exit 1
fi

echo "Secret scan passed."

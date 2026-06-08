#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== Migration safety check =="

if [[ ! -d server/migrations ]]; then
  echo "No server/migrations directory; skipped."
  exit 0
fi

# 禁止未确认的破坏性 SQL 进入默认 CI。
if grep -RInE \
  --include='*.sql' \
  '\b(DROP[[:space:]]+TABLE|TRUNCATE[[:space:]]+TABLE|DELETE[[:space:]]+FROM|DROP[[:space:]]+DATABASE)\b' \
  server/migrations; then
  echo "Dangerous SQL found in migrations. Require explicit review and approval."
  exit 1
fi

# 检查 migration 记录写入。
for file in server/migrations/*.sql; do
  [[ -e "$file" ]] || continue
  if ! grep -q "schema_migrations" "$file"; then
    echo "Migration does not record schema_migrations: $file"
    exit 1
  fi
  if ! grep -q "utf8mb4" "$file"; then
    echo "Migration should use utf8mb4 charset/collation where tables/databases are created: $file"
    exit 1
  fi
done

echo "Migration safety check passed."
